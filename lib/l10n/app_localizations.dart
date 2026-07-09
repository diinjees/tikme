import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('so'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TikMe'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover and share amazing videos from around the world.'**
  String get appDescription;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'TikMe is a short video sharing application inspired by popular platforms. Users can upload, view, like, and comment on short videos. It features user authentication, profile management, and a personalized video feed.'**
  String get aboutDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version: {version}'**
  String appVersion(Object version);

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by: Jstech'**
  String get developedBy;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us: metube-support@google.com'**
  String get contactUs;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupButton;

  /// No description provided for @noAccountSignup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignup;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed: {error}'**
  String signUpFailed(Object error);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get inbox;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingCount;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @shares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get shares;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPosts;

  /// No description provided for @createFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Create your first post!'**
  String get createFirstPost;

  /// No description provided for @loadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Loading posts...'**
  String get loadingPosts;

  /// No description provided for @errorLoadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Error loading posts'**
  String get errorLoadingPosts;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @noUploadedVideos.
  ///
  /// In en, this message translates to:
  /// **'No uploaded videos yet.'**
  String get noUploadedVideos;

  /// No description provided for @noLikedVideos.
  ///
  /// In en, this message translates to:
  /// **'No liked videos yet.'**
  String get noLikedVideos;

  /// No description provided for @pickVideo.
  ///
  /// In en, this message translates to:
  /// **'Please select a video first'**
  String get pickVideo;

  /// No description provided for @pickVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Pick Video'**
  String get pickVideoButton;

  /// No description provided for @uploadVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideoButton;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add Video Description'**
  String get addDescription;

  /// No description provided for @videoUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully!'**
  String get videoUploadSuccess;

  /// No description provided for @videoUploadFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload video: {error}'**
  String videoUploadFailure(Object error);

  /// No description provided for @errorPickingVideo.
  ///
  /// In en, this message translates to:
  /// **'Error picking video: {error}'**
  String errorPickingVideo(Object error);

  /// No description provided for @nologinupload.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to upload a video.'**
  String get nologinupload;

  /// No description provided for @videoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Video file is too large (max 50MB)'**
  String get videoTooLarge;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @changeVideo.
  ///
  /// In en, this message translates to:
  /// **'Change Video'**
  String get changeVideo;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @nofollowers.
  ///
  /// In en, this message translates to:
  /// **'No followers yet.'**
  String get nofollowers;

  /// No description provided for @nofollowings.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet.'**
  String get nofollowings;

  /// No description provided for @errorfollower.
  ///
  /// In en, this message translates to:
  /// **'Error loading followers'**
  String get errorfollower;

  /// No description provided for @errorfollowing.
  ///
  /// In en, this message translates to:
  /// **'Error loading following'**
  String get errorfollowing;

  /// No description provided for @failedfollow.
  ///
  /// In en, this message translates to:
  /// **'Failed to: {error} Please try again.'**
  String failedfollow(Object error);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSettings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @newemail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newemail;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// No description provided for @newUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get newUsernameHint;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter old password'**
  String get oldPasswordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordHint;

  /// No description provided for @noEmailSet.
  ///
  /// In en, this message translates to:
  /// **'No email set.'**
  String get noEmailSet;

  /// No description provided for @dosenotMacth.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get dosenotMacth;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @usernameChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Username changed successfully.'**
  String get usernameChangedSuccessfully;

  /// No description provided for @confirmationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent. Please check your inbox.'**
  String get confirmationEmailSent;

  /// No description provided for @failedToChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to change email: {error}'**
  String failedToChangeEmail(Object error);

  /// No description provided for @failedToChangeUsername.
  ///
  /// In en, this message translates to:
  /// **'Failed to change username: {error}'**
  String failedToChangeUsername(Object error);

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password: {error}'**
  String failedToChangePassword(Object error);

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @settingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButton;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search users, videos...'**
  String get searchHint;

  /// No description provided for @searchM.
  ///
  /// In en, this message translates to:
  /// **'Search Users Message'**
  String get searchM;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYou;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get addComment;

  /// No description provided for @postComment.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postComment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @viewReplies.
  ///
  /// In en, this message translates to:
  /// **'View {count} replies'**
  String viewReplies(Object count);

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hideReplies;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noComments;

  /// No description provided for @beFirstComment.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment'**
  String get beFirstComment;

  /// No description provided for @failedToPostComment.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment: {error}'**
  String failedToPostComment(Object error);

  /// No description provided for @notificationLiked.
  ///
  /// In en, this message translates to:
  /// **'{username} liked your video'**
  String notificationLiked(Object username);

  /// No description provided for @notificationCommented.
  ///
  /// In en, this message translates to:
  /// **'{username} commented on your video'**
  String notificationCommented(Object username);

  /// No description provided for @notificationFollowed.
  ///
  /// In en, this message translates to:
  /// **'{username} started following you'**
  String notificationFollowed(Object username);

  /// No description provided for @notificationShared.
  ///
  /// In en, this message translates to:
  /// **'{username} shared your video'**
  String notificationShared(Object username);

  /// No description provided for @notificationMentioned.
  ///
  /// In en, this message translates to:
  /// **'{username} mentioned you in a comment'**
  String notificationMentioned(Object username);

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get sendMessage;

  /// No description provided for @sendmessage.
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get sendmessage;

  /// No description provided for @nomessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start a conversation!'**
  String get nomessages;

  /// No description provided for @defaultUsername.
  ///
  /// In en, this message translates to:
  /// **'TikMe User'**
  String get defaultUsername;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @deletemessages.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deletemessages;

  /// No description provided for @deleteMesDes.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this message or all your messages in this conversation?'**
  String get deleteMesDes;

  /// No description provided for @deleteAllmessages.
  ///
  /// In en, this message translates to:
  /// **'Delete All My Messages'**
  String get deleteAllmessages;

  /// No description provided for @deletebutton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletebutton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteCon.
  ///
  /// In en, this message translates to:
  /// **'Delete All Conversations'**
  String get deleteCon;

  /// No description provided for @deleteConDes.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all conversations? This action cannot be undone.'**
  String get deleteConDes;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully!'**
  String get profilePictureUpdated;

  /// No description provided for @failedToUploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload profile picture: {error}'**
  String failedToUploadProfilePicture(Object error);

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @noDownloads.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloads;

  /// No description provided for @downloadCompleted.
  ///
  /// In en, this message translates to:
  /// **'Download completed'**
  String get downloadCompleted;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @externalVideos.
  ///
  /// In en, this message translates to:
  /// **'External Videos'**
  String get externalVideos;

  /// No description provided for @pasteVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste video URL'**
  String get pasteVideoUrl;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noExternalVideos.
  ///
  /// In en, this message translates to:
  /// **'No external videos'**
  String get noExternalVideos;

  /// No description provided for @addVideoUrlsHint.
  ///
  /// In en, this message translates to:
  /// **'Add YouTube, TikTok, Instagram video URLs'**
  String get addVideoUrlsHint;

  /// No description provided for @invalidVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid video URL'**
  String get invalidVideoUrl;

  /// No description provided for @videoAdded.
  ///
  /// In en, this message translates to:
  /// **'Video added successfully'**
  String get videoAdded;

  /// No description provided for @cannotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Cannot launch URL'**
  String get cannotLaunchUrl;

  /// No description provided for @supportedPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Supported Platforms'**
  String get supportedPlatforms;

  /// No description provided for @linkdownload.
  ///
  /// In en, this message translates to:
  /// **'Link Download'**
  String get linkdownload;

  /// No description provided for @deletevideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get deletevideo;

  /// Confirmation message for deleting a video
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{fileName}\"?'**
  String deletesure(Object fileName);

  /// Success message after deleting a video
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" deleted successfully'**
  String deletesuccessfully(Object fileName);

  /// No description provided for @deleteall.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteall;

  /// No description provided for @deletealldownload.
  ///
  /// In en, this message translates to:
  /// **'Delete All Downloads'**
  String get deletealldownload;

  /// Confirmation message for deleting all downloaded videos
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all {count} downloaded videos? This action cannot be undone.'**
  String deletealldownloadsure(Object count);

  /// Success message after deleting multiple videos
  ///
  /// In en, this message translates to:
  /// **'{count} videos deleted successfully'**
  String deletevideosuccessfully(Object count);

  /// No description provided for @filelocation.
  ///
  /// In en, this message translates to:
  /// **'File Location'**
  String get filelocation;

  /// No description provided for @storagereq.
  ///
  /// In en, this message translates to:
  /// **'Storage Access Required'**
  String get storagereq;

  /// No description provided for @storagereqsure.
  ///
  /// In en, this message translates to:
  /// **'To view and manage your downloaded videos, please allow storage access permission. This allows the app to access videos saved in your Movies folder.'**
  String get storagereqsure;

  /// No description provided for @grantpermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantpermission;

  /// No description provided for @opensettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get opensettings;

  /// No description provided for @downloadtitel.
  ///
  /// In en, this message translates to:
  /// **'Downloaded videos will appear here.\nVideos are saved to Movies/TikMe folder on your device.'**
  String get downloadtitel;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get location;

  /// No description provided for @loadingdownload.
  ///
  /// In en, this message translates to:
  /// **'Loading downloads...'**
  String get loadingdownload;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Downloads'**
  String get refresh;

  /// No description provided for @videoPlayer.
  ///
  /// In en, this message translates to:
  /// **'Video Player'**
  String get videoPlayer;

  /// No description provided for @documentSharing.
  ///
  /// In en, this message translates to:
  /// **'Document Sharing'**
  String get documentSharing;

  /// No description provided for @loadingvideo.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get loadingvideo;

  /// No description provided for @videonotwork.
  ///
  /// In en, this message translates to:
  /// **'The video file may be corrupted or unavailable'**
  String get videonotwork;

  /// No description provided for @videofailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get videofailed;

  /// No description provided for @videonotavailable.
  ///
  /// In en, this message translates to:
  /// **'Video not available'**
  String get videonotavailable;

  /// No description provided for @novideofound.
  ///
  /// In en, this message translates to:
  /// **'No Video found'**
  String get novideofound;

  /// No description provided for @goback.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goback;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @detailsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Details: {videoId}'**
  String detailsScreenTitle(Object videoId);

  /// No description provided for @viewingVideoWithId.
  ///
  /// In en, this message translates to:
  /// **'Viewing video with ID: {videoId}'**
  String viewingVideoWithId(Object videoId);

  /// No description provided for @videoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get videoTitleLabel;

  /// No description provided for @videoDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Video Description'**
  String get videoDescriptionLabel;

  /// No description provided for @noVideoSelected.
  ///
  /// In en, this message translates to:
  /// **'No video selected.'**
  String get noVideoSelected;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressAgainToExit;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @failedToToggleFollow.
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle follow state: {error}'**
  String failedToToggleFollow(Object error);

  /// No description provided for @failedToUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Failed to unfollow. Please try again.'**
  String get failedToUnfollow;

  /// No description provided for @failedToFollow.
  ///
  /// In en, this message translates to:
  /// **'Failed to follow. Please try again.'**
  String get failedToFollow;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get invalidPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please try again'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'so':
      return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
