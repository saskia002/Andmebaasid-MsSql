/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [master]
GO

/****** Object:  Database [MiniInsta]    Script Date: 06.11.2017 20:25:23 ******/
CREATE DATABASE [MiniInsta]
/*
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MiniInsta', FILENAME = N'C:\SQL\Data\MiniInsta.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MiniInsta_log', FILENAME = N'C:\SQL\Log\MiniInsta_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
*/
GO

ALTER DATABASE [MiniInsta] SET COMPATIBILITY_LEVEL = 140
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MiniInsta].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

USE MiniInsta;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Gender](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,

	CONSTRAINT [PK_Gender] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[User](
	[ID] [int] NOT NULL,
	[Username] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Website] [nvarchar](250) NOT NULL,
	[GenderID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Email] [nvarchar](250) NOT NULL,
	[CreationTime] [datetime2](7) NOT NULL,
	[Password] nvarchar(250) NOT NULL,
	[ImageUrl] nvarchar(250) NOT NULL,

	CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
) 
GO

CREATE TABLE [dbo].[Post](
	[ID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CreationTime] [datetime2](7) NOT NULL,
	[Location] [geography] NULL,
	[LocationName] [nvarchar](250) NULL,

	CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO


CREATE TABLE [dbo].[MediaType](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,

	CONSTRAINT [PK_MediaType] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[PostMedia](
	[ID] [int] NOT NULL,
	[PostID] [int] NOT NULL,
	[MediaFileUrl] [nvarchar](500) NOT NULL,
	[MediaTypeID] [int] NOT NULL,

	CONSTRAINT [PK_PostMedia] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Comment](
	[ID] [int] NOT NULL,
	[PostID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreationTime] [datetime2](7) NOT NULL,

	CONSTRAINT [PK_Comment] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Liking](
	[UserID] [int] NOT NULL,
	[PostID] [int] NOT NULL,
	[CreationTime] [datetime2](7) NOT NULL,

	CONSTRAINT [PK_Liking] PRIMARY KEY CLUSTERED 
	(
		[UserID] ASC,
		[PostID] ASC
	)
)
GO


CREATE TABLE [dbo].[Following](
	[FollowerID] [int] NOT NULL,
	[FolloweeID] [int] NOT NULL,
	[CreationTime] [datetime2](7) NOT NULL,

	CONSTRAINT [PK_Following] PRIMARY KEY CLUSTERED 
	(
		[FollowerID] ASC,
		[FolloweeID] ASC
	)
) 
GO




ALTER TABLE [dbo].[Following] ADD  CONSTRAINT [DF_Following_CreationTime]  DEFAULT (sysdatetime()) FOR [CreationTime]
GO
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_Website]  DEFAULT (N'') FOR [Website]
GO
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_GenderID]  DEFAULT ((1)) FOR [GenderID]
GO
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_Email]  DEFAULT (N'') FOR [Email]
GO
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_CreationTime]  DEFAULT (sysdatetime()) FOR [CreationTime]
GO
ALTER TABLE [dbo].[Comment] ADD  CONSTRAINT [DF_Comment_CreationTime]  DEFAULT (sysdatetime()) FOR [CreationTime]
GO
ALTER TABLE [dbo].[Liking] ADD  CONSTRAINT [DF_Liking_CreationTime]  DEFAULT (sysdatetime()) FOR [CreationTime]
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_CreationTime]  DEFAULT (sysdatetime()) FOR [CreationTime]
GO
ALTER TABLE [dbo].[PostMedia] ADD  CONSTRAINT [DF_PostMedia_MediaTypeID]  DEFAULT ((1)) FOR [MediaTypeID]
GO
ALTER TABLE [dbo].[Following]  WITH CHECK ADD  CONSTRAINT [FK_Following_Follower] FOREIGN KEY([FollowerID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Following] CHECK CONSTRAINT [FK_Following_Follower]
GO
ALTER TABLE [dbo].[Following]  WITH CHECK ADD  CONSTRAINT [FK_Following_Followee] FOREIGN KEY([FolloweeID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Following] CHECK CONSTRAINT [FK_Following_Followee]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Gender] FOREIGN KEY([GenderID])
REFERENCES [dbo].[Gender] ([ID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Gender]
GO
ALTER TABLE [dbo].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Comment_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Comment] CHECK CONSTRAINT [FK_Comment_User]
GO
ALTER TABLE [dbo].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Comment_Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[Post] ([ID])
GO
ALTER TABLE [dbo].[Comment] CHECK CONSTRAINT [FK_Comment_Post]
GO
ALTER TABLE [dbo].[Liking]  WITH CHECK ADD  CONSTRAINT [FK_Liking_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Liking] CHECK CONSTRAINT [FK_Liking_User]
GO
ALTER TABLE [dbo].[Liking]  WITH CHECK ADD  CONSTRAINT [FK_Liking_Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[Post] ([ID])
GO
ALTER TABLE [dbo].[Liking] CHECK CONSTRAINT [FK_Liking_Post]
GO
ALTER TABLE [dbo].[Post]  WITH CHECK ADD  CONSTRAINT [FK_Post_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Post] CHECK CONSTRAINT [FK_Post_User]
GO
ALTER TABLE [dbo].[PostMedia]  WITH CHECK ADD  CONSTRAINT [FK_PostMedia_MediaType] FOREIGN KEY([MediaTypeID])
REFERENCES [dbo].[MediaType] ([ID])
GO
ALTER TABLE [dbo].[PostMedia] CHECK CONSTRAINT [FK_PostMedia_MediaType]
GO
ALTER TABLE [dbo].[PostMedia]  WITH CHECK ADD  CONSTRAINT [FK_PostMedia_Post] FOREIGN KEY([PostID])
REFERENCES [dbo].[Post] ([ID])
GO
ALTER TABLE [dbo].[PostMedia] CHECK CONSTRAINT [FK_PostMedia_Post]
GO

