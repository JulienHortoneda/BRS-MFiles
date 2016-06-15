﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using MFilesAPI;
namespace MFilesLib
{
    public static class ProcessVaults
    {
        private static MFilesServerApplication _mfilesServer;

        private static void ProcessData(string vaultName, Vault vault, IView view, DateTime startDate, IProcessor processor)
        {
            Trace.TraceInformation($"Hello from {vaultName}");

            var conditions = view.SearchConditions;
            var dfDate = new DataFunctionCall();
            dfDate.SetDataDate();

            var search = new SearchCondition();
            var expression = new Expression();
            var value = new TypedValue();

            expression.SetPropertyValueExpression((int)MFBuiltInPropertyDef.MFBuiltInPropertyDefLastModified,
                MFParentChildBehavior.MFParentChildBehaviorNone, dfDate);
            search.Set(expression, MFConditionType.MFConditionTypeGreaterThanOrEqual, value);

            conditions.Add(-1, search);

            search = new SearchCondition();
            expression = new Expression();
            value = new TypedValue();
            expression.SetPropertyValueExpression((int)MFBuiltInPropertyDef.MFBuiltInPropertyDefLastModified,
                MFParentChildBehavior.MFParentChildBehaviorNone, dfDate);
            search.Set(expression, MFConditionType.MFConditionTypeLessThan, value);

            conditions.Add(-1, search);


            var currentDateTime = startDate;

            while (currentDateTime < DateTime.Now)
            {
                conditions[conditions.Count - 1].TypedValue.SetValue(MFDataType.MFDatatypeDate, currentDateTime);
                currentDateTime = currentDateTime.AddMonths(1);
                conditions[conditions.Count].TypedValue.SetValue(MFDataType.MFDatatypeDate, currentDateTime);


                ObjectSearchResults objects = vault.ObjectSearchOperations.SearchForObjectsByConditionsEx(conditions,
                    MFSearchFlags.MFSearchFlagReturnLatestVisibleVersion, false, 0);

                foreach (ObjectVersion objVer in objects)
                {
                    processor.ProcessObject(objVer, vaultName, vault);
                }
                //internalDocuments.AddRange(from ObjectVersion obj in objects
                //                            select new MFilesInternalDocument(internalVault, obj));
            }
        }

        public static void Run(string serverName, string userName, string password, string[] vaultNames, string viewName, DateTime startDate, IProcessor processor)
        {
            _mfilesServer = new MFilesServerApplication();
            MFServerConnection result;
            try
            {
                result = _mfilesServer.Connect(MFAuthType.MFAuthTypeSpecificMFilesUser, userName, password,
                    NetworkAddress: serverName);
            }
            catch (COMException ex)
            {
                Trace.TraceError($"Could not connecto to M-Files server {ex.Message}");
                return;
            }
            if (result != MFServerConnection.MFServerConnectionAuthenticated)
            {
                Trace.TraceError("Could not connecto to M-Files server");
                return;
            }

            Trace.TraceInformation($"Hello from Run {serverName}");

            VaultsOnServer vaultsOnServer = _mfilesServer.GetVaults();
           
            IList<Tuple<string, Vault, IView>> data = new List<Tuple<string, Vault, IView>>();
            foreach (string vaultName in vaultNames)
            {
                IVaultOnServer vaultOnServer;
                try
                {
                    vaultOnServer = vaultsOnServer.GetVaultByName(vaultName);
                }
                catch (COMException)
                {
                    Trace.TraceError($"Could not find vault '{vaultName}'");
                    continue;
                }
 
                Vault vault = vaultOnServer.LogIn();
                if (!vault.LoggedIn)
                {
                    Trace.TraceError($"Could not logging to vault '{vaultName}'");
                    continue;
                }

                IView view = vault.ViewOperations.GetViews().Cast<IView>().FirstOrDefault(v => v.Name == viewName);
                if (view == null)
                {
                    Trace.TraceWarning($"Could not find view '{viewName}' in vault  '{vaultName}'");
                    continue;
                }
                data.Add(Tuple.Create(vaultName, vault, view));
            }

            IList<Task> tasks = new List<Task>();
            foreach (var taskData in data)
            {
                var task = new Task(() => ProcessData(taskData.Item1, taskData.Item2, taskData.Item3, startDate, processor));
                tasks.Add(task);
                task.Start();
            }

            foreach (var task in tasks)
            {
                task.Wait();
            }

 

        }
    }
}