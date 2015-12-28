//
//  Define.h
//  Skope
//
//  Created by Huynh Phong Chau on 2/20/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#define APP_NAME @"Skope"

#define QUICKBLOX_PASSWORD @"skope123"
//Unit: mets
#define DISTANCE_FILTER_LOCATION 100
//Unit : seconds
#define TIME_TO_RECALL_WS_UPDATE_LOCATION 15

#define TIME_TO_RESTART_CHECKING_LOCATION 15
#define TIME_TO_RESTART_LOCATION 15

#define APP_DELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

#define FONT_COLOR_TEXT_CAMERA_CHOOSE [UIColor colorWithRed:0.109 green:0.372 blue:0.674 alpha:1.0]
#define FONT_TEXT_CAMERA_CHOOSE [UIFont fontWithName:@"HelveticaNeue" size:20.0f]
#define FONT_TEXT_CAMERA_CHOOSE_BOLD [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f]

#define FONT_TEXT_COMMENTS_NAME [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]
#define FONT_TEXT_COMMENTS_DATE [UIFont fontWithName:@"HelveticaNeue" size:11.0f]

#define FONT_TEXT_CONTENT_POST [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]
#define FONT_TEXT_COMMENTS [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]
#define FONT_TEXT_POST [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define COLOR_GREEN_LIKE [UIColor colorWithRed:0.525 green:0.815 blue:0.239 alpha:1.0]
#define COLOR_BUTTON_POST_SEND [UIColor colorWithRed:0.525 green:0.815 blue:0.239 alpha:1.0]

#define SIZE_IMAGE_AFTER_CAPTURE CGSizeMake(350, 350)

#define HEIGHT_NAME_AREA_POST_LIST 115
#define HEIGHT_LIKE_DISLIKE_AREA_POST_LIST 70
#define WIDTH_CONTENT_AREA_POST_LIST 290
#define HEIGHT_COMMENT_AREA_POST_LIST 60

#define WIDTH_COMMENT_AREA_POST_LIST 280
#define WIDTH_COMMENT_AREA_POST_LIST6 330
#define WIDTH_COMMENT_AREA_POST_LIST6P 370

#define WIDTH_LIKE_COMMENT_AREA_POST_LIST 310
#define HEIGHT_LIKE_COMMENT_AREA_POST_LIST 140

#define WIDTH_A_IMAGE_VIDEO_POST 74

#define MSS_TRY_AGAIN @"Try again!"
#define LIMIT_LIST_POST 10

#define HEIGHT_SLIDE_IMAGE_POST_LIST 230

//Login
#define TITLE_CANCEL_BT_ALERT @"OK"
#define MSS_LOGIN_TRY_AGAIN @"Try again!"

#define maximumCircleSlider 101.0f
#define minximumCircleSlider 1.0f
#define unitRadiusCircleSlider 1000.0f

//Map
#define radiusInit 1000

//LIKE DISLIKE FONT AND COLOR
#define COLOR_LIKE_ENABLE [UIColor colorWithRed:0.490 green:0.741 blue:0.101 alpha:1.0]
#define COLOR_DISLIKE_ENABLE [UIColor colorWithRed:0.80 green:0.172 blue:0.176 alpha:1.0]
#define COLOR_LIKE_DISLIKE_DISABLE [UIColor lightGrayColor]
#define FONT_LIKE_DISLIKE_ENABLE [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f]
#define FONT_LIKE_DISLIKE_DISABLE [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
//-----------------------------------------------------------------------
#define		PF_CHAT_CLASS_NAME					@"Chat"					//	Class name
#define		PF_CHAT_USER						@"user"					//	Pointer to User Class
#define		PF_CHAT_GROUPID						@"groupId"				//	String
#define		PF_CHAT_TEXT						@"text"					//	String
#define		PF_CHAT_PICTURE						@"picture"				//	File
#define		PF_CHAT_VIDEO						@"video"				//	File
#define		PF_CHAT_CREATEDAT					@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String
//-----------------------------------------------------------------------
#define		PF_MESSAGES_CLASS_NAME				@"Messages"				//	Class name
#define		PF_MESSAGES_USER					@"user"					//	Pointer to User Class
#define		PF_MESSAGES_GROUPID					@"groupId"				//	String
#define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
#define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer to User Class
#define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_MESSAGES_COUNTER					@"counter"				//	Number
#define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"





