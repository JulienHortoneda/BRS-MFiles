USE [BRS-Documents]
GO
/****** Object:  View [dbo].[informea_DecisionsDocs]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_DecisionsDocs]
AS
SELECT     1 AS protocolVersion, dbo.Documents.DocumentId AS id, NULL AS link, CASE CHARINDEX('/CRC.', Documents.UnNumber) 
                      WHEN 0 THEN 'decision' ELSE 'recommendation' END AS type, 'active' AS status, REVERSE(LEFT(REVERSE('/' + dbo.Documents.UnNumber), 
                      CHARINDEX('/', REVERSE('/' + dbo.Documents.UnNumber), CHARINDEX('-', REVERSE('/' + dbo.Documents.UnNumber))) - 1)) AS number, 
                      dbo.Documents.Convention AS treaty, dbo.Documents.PublicationDate AS published, dbo.Documents.PublicationDate AS updated,
                          (SELECT     dbo.fn_getCrmMeetingId(dbo.Documents.Convention, dbo.ListProperties.Value) AS Expr1) AS meetingId, NULL AS meetingTitle, NULL 
                      AS meetingUrl, dbo.Documents.UnNumber AS BrsUnNumber, dbo.ListProperties.Value AS brsMeetingAccronym,
                          (SELECT     dbo.fn_getDocDisplayOrder(dbo.Documents.UnNumber) AS Expr1) AS displayOrder
FROM         dbo.Documents INNER JOIN
                      dbo.DocumentsTypes ON dbo.Documents.DocumentId = dbo.DocumentsTypes.DocumentId INNER JOIN
                      dbo.DocumentsMeetings ON dbo.Documents.DocumentId = dbo.DocumentsMeetings.DocumentId INNER JOIN
                      dbo.ListProperties ON dbo.DocumentsMeetings.PropertyId = dbo.ListProperties.ListPropertyId
WHERE     (CHARINDEX('/', dbo.Documents.UnNumber) > 0) AND (CHARINDEX('/IG.', dbo.Documents.UnNumber) = 0) AND 
                      (dbo.DocumentsTypes.PropertyId = '6B8DC1F3-2CBF-43F7-AC43-E510AC98BA73' OR
                      dbo.DocumentsTypes.PropertyId = 'E926D163-0CED-4013-8BCE-0932CF1A5360') AND (CHARINDEX('Ex-', dbo.Documents.UnNumber) = 0)


GO
/****** Object:  View [dbo].[informea_BcDecisionsDocs]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_BcDecisionsDocs]
AS
SELECT     protocolVersion, id, link, type, status, number, treaty, published, updated, meetingId, meetingTitle, meetingUrl, displayOrder, BrsUnNumber, 
                      brsMeetingAccronym
FROM         dbo.informea_DecisionsDocs
WHERE     (treaty = N'basel')


GO
/****** Object:  View [dbo].[informea_RcDecisionsDocs]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_RcDecisionsDocs]
AS
SELECT     protocolVersion, id, link, type, status, number, treaty, published, updated, meetingId, meetingTitle, meetingUrl, displayOrder
FROM         dbo.informea_DecisionsDocs
WHERE     (treaty = N'rotterdam')


GO
/****** Object:  View [dbo].[informea_ScDecisionsDocs]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_ScDecisionsDocs]
AS
SELECT     protocolVersion, id, link, type, status, number, treaty, published, updated, meetingId, meetingTitle, meetingUrl, displayOrder
FROM         dbo.informea_DecisionsDocs
WHERE     (treaty = N'stockholm')

GO
/****** Object:  View [dbo].[informea_DecisionsPrograms]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[informea_DecisionsPrograms]
AS
SELECT     dbo.ListProperties.ListPropertyId AS id, 
			(SELECT TOP(1) [brs_RelatedInformeaTerms] FROM [212.203.125.119].[AdxstudioPortals05015_MSCRM].[dbo].[brs_term] WHERE statecode = 0 and statuscode = 1 and  brs_name collate SQL_Latin1_General_CP1_CI_AS = ListProperties.Value collate SQL_Latin1_General_CP1_CI_AS) as informeaTermId, 
			'http://www.unep.org' AS namespace, dbo.ListProperties.Value AS term, 
                      dbo.DocumentsPrograms.DocumentId AS documentId
FROM         dbo.DocumentsPrograms INNER JOIN
                      dbo.ListProperties ON dbo.DocumentsPrograms.PropertyId = dbo.ListProperties.ListPropertyId INNER JOIN
                      dbo.informea_DecisionsDocs ON dbo.DocumentsPrograms.DocumentId = dbo.informea_DecisionsDocs.id



GO
/****** Object:  View [dbo].[informea_DecisionsContent]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_DecisionsContent]
AS
SELECT        NULL AS id, DocumentId AS documentId, NULL AS language, NULL AS value
FROM            dbo.Documents
WHERE        (DocumentId IS NULL)


GO
/****** Object:  View [dbo].[informea_DecisionsFiles]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_DecisionsFiles]
AS
SELECT     FileId AS id, Url AS url, MimeType AS mimeType, Language AS language, Name AS fileName, Document_DocumentId AS documentId
FROM         dbo.Files


GO
/****** Object:  View [dbo].[informea_DecisionsSummary]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_DecisionsSummary]
AS
SELECT     DescriptionId AS id, Document_DocumentId AS documentId, Language AS language, Value AS value
FROM         dbo.Descriptions


GO
/****** Object:  View [dbo].[informea_DecisionsTitles]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[informea_DecisionsTitles]
AS
SELECT     TitleId AS id, Document_DocumentId AS documentId, Language AS language, Value AS value
FROM         dbo.Titles


GO
/****** Object:  View [dbo].[mea_AuthorDocuments]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[mea_AuthorDocuments]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Documents.DocumentId) as authorId,  CONVERT(nvarchar(36), Documents.DocumentId) as documentId FROM dbo.Documents 
	WHERE NULLIF(Documents.Author , '') IS NOT NULL;


GO
/****** Object:  View [dbo].[mea_Authors]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_Authors]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Documents.DocumentId) as id, 'organization' as [type], Documents.Author as value  FROM dbo.Documents 
	WHERE NULLIF(Documents.Author , '') IS NOT NULL;



GO
/****** Object:  View [dbo].[mea_Descriptions]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_Descriptions]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Descriptions.DescriptionId) as id,CONVERT(nvarchar(36), Descriptions.Document_DocumentId) as documentId, Language as language, Value as value FROM dbo.Descriptions;


GO
/****** Object:  View [dbo].[mea_Documents]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[mea_Documents] WITH SCHEMABINDING
	AS SELECT '1.0' as schemaVersion, Documents.DocumentId as brs_id, CONVERT(nvarchar(36), Documents.DocumentId) as id,
	MFilesDocuments.CreatedDate as published, MFilesDocuments.ModifiedDate as updated,
	Documents.Convention as treaty, Documents.Copyright as copyright,Files.ThumbnailUrl as thumbnailUrl, Documents.Country as country, 0 as displayOrder
	FROM dbo.[Documents] INNER JOIN dbo.MFilesDocuments ON MFilesDocuments.Guid = Documents.DocumentId INNER JOIN dbo.Files ON Documents.DocumentId = Files.FileId ;

GO
/****** Object:  View [dbo].[mea_Files]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_Files]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Files.FileId) as id, CONVERT(nvarchar(36), Files.Document_DocumentId) as documentId, Files.Url as url, NULL as content, Files.MimeType as mimeType, Files.Language as language, Files.Name + '.' + Files.Extension as filename, Files.Extension as brsExtension,
	Files.Size as brsSize FROM  dbo.Files;

GO
/****** Object:  View [dbo].[mea_Identifiers]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_Identifiers]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Documents.DocumentId) as id, CONVERT(nvarchar(36), Documents.DocumentId) as documentId, 'UN-Number' as identifierName, UnNumber as identifierValue FROM dbo.Documents;


GO
/****** Object:  View [dbo].[mea_KeywordDocuments]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[mea_KeywordDocuments]
	WITH SCHEMABINDING
	AS SELECT PropertyId as brs_keywordId, DocumentId as brs_documentId, CONVERT(NVARCHAR(36), PropertyId)  as keywordId, CONVERT(NVARCHAR(36), DocumentId) as documentId FROM dbo.DocumentsTerms
	UNION SELECT LeoTermId as brs_keywordId, DocumentId as brs_documentId, CONVERT(NVARCHAR(36), LeoTermId)  as keywordId, CONVERT(NVARCHAR(36), DocumentId) as documentId 
	FROM dbo.LeoTerms INNER JOIN [dbo].[LeoTermListProperties]  ON LeoTermId=[LeoTerm_LeoTermId] INNER JOIN dbo.DocumentsTerms ON [ListProperty_ListPropertyId]=PropertyId;



GO
/****** Object:  View [dbo].[mea_Keywords]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[mea_Keywords]
WITH SCHEMABINDING
	AS SELECT ListProperties.ListPropertyId as brs_id, CONVERT(nvarchar(36), ListProperties.ListPropertyId) as id, 'http://www.brsmeas.org/terms/' + Value  as termURI, 'brs' as scope, Value as termValueInEnglish FROM dbo.ListProperties WHERE ListProperties.ListPropertyId IN (SELECT DISTINCT PropertyId FROM dbo.DocumentsTerms)
	UNION SELECT LeoTerms.LeoTermId as brs_id, CONVERT(nvarchar(36), LeoTerms.LeoTermId) as id, [Url]  as termURI, 'LEO' as scope, Name as termValueInEnglish FROM dbo.LeoTerms;




GO
/****** Object:  View [dbo].[mea_ReferenceToEntity]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_ReferenceToEntity]
	AS SELECT CONVERT(NVARCHAR(36), ListProperties.ListPropertyId) as id, 'meeting' as entityType, ListProperties.Url as refURI FROM ListProperties INNER JOIN ListPropertyTypeListProperties ON ListProperties.ListPropertyId = ListPropertyTypeListProperties.ListProperty_ListPropertyId INNER JOIN ListPropertyTypes ON  ListPropertyTypeListProperties.ListPropertyType_ListPropertyTypeId = ListPropertyTypes.ListPropertyTypeId WHERE ListPropertyTypes.Name='meeting' AND  ListProperties.Url IS NOT NULL


GO
/****** Object:  View [dbo].[mea_ReferenceToEntityDocuments]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_ReferenceToEntityDocuments]
	WITH SCHEMABINDING
	AS SELECT CONVERT(NVARCHAR(36), PropertyId)  as referenceToEntityId, CONVERT(NVARCHAR(36), documentId) as documentId FROM dbo.DocumentsMeetings INNER JOIN dbo.ListProperties ON PropertyId=ListPropertyId WHERE ListProperties.Url IS NOT NULL


GO
/****** Object:  View [dbo].[mea_TagDocuments]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[mea_TagDocuments]
	WITH SCHEMABINDING
	AS SELECT CONVERT(NVARCHAR(36), PropertyId)  as tagId, CONVERT(NVARCHAR(36), DocumentId) as documentId FROM dbo.DocumentsChemicals
	UNION SELECT CONVERT(NVARCHAR(36), PropertyId)  as tagId, CONVERT(NVARCHAR(36), DocumentId) as documentId FROM dbo.DocumentsTerms
	UNION SELECT CONVERT(NVARCHAR(36), PropertyId)  as tagId, CONVERT(NVARCHAR(36), DocumentId) as documentId FROM dbo.DocumentsPrograms;







GO
/****** Object:  View [dbo].[mea_Tags]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[mea_Tags]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), ListProperties.ListPropertyId) as id, ListProperties.Value as value, 'en' as language, 'chemical' as scope, '' as comment FROM  dbo.ListProperties WHERE ListProperties.ListPropertyId IN (SELECT DISTINCT PropertyId FROM dbo.DocumentsChemicals)
UNION SELECT CONVERT(nvarchar(36), ListProperties.ListPropertyId) as id, ListProperties.Value as value, 'en' as language, 'brs-term' as scope, '' as comment FROM  dbo.ListProperties WHERE ListProperties.ListPropertyId IN (SELECT DISTINCT PropertyId FROM dbo.DocumentsTerms)
UNION SELECT CONVERT(nvarchar(36), ListProperties.ListPropertyId) as id, ListProperties.Value as value, 'en' as language, 'brs-programme' as scope, '' as comment FROM  dbo.ListProperties WHERE ListProperties.ListPropertyId IN (SELECT DISTINCT PropertyId FROM dbo.DocumentsPrograms);




GO
/****** Object:  View [dbo].[mea_Titles]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_Titles]
WITH SCHEMABINDING
	AS SELECT CONVERT(nvarchar(36), Titles.TitleId) as id, CONVERT(nvarchar(36),Titles.Document_DocumentId) as documentId, Language as language, Value as value FROM dbo.Titles;


GO
/****** Object:  View [dbo].[mea_TypeDocuments]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mea_TypeDocuments]
	WITH SCHEMABINDING
	AS SELECT CONVERT(NVARCHAR(36), PropertyId)  as typeId, CONVERT(NVARCHAR(36), DocumentId) as documentId FROM dbo.DocumentsTypes;



GO
/****** Object:  View [dbo].[mea_Types]    Script Date: 20/11/2016 18:55:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[mea_Types] WITH SCHEMABINDING 
	AS SELECT CONVERT(nvarchar(36), ListProperties.ListPropertyId) as id, Value as value FROM dbo.ListProperties WHERE ListProperties.ListPropertyId IN (SELECT DISTINCT PropertyId FROM dbo.DocumentsTypes);


GO
