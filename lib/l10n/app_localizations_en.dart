// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TikMe';

  @override
  String get appDescription =>
      'Discover and share amazing videos from around the world.';

  @override
  String get aboutDescription =>
      'TikMe is a short video sharing application inspired by popular platforms. Users can upload, view, like, and comment on short videos. It features user authentication, profile management, and a personalized video feed.';

  @override
  String appVersion(Object version) {
    return 'App Version: $version';
  }

  @override
  String get developedBy => 'Developed by: Jstech';

  @override
  String get contactUs => 'Contact us: metube-support@google.com';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get username => 'Username';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Create Account';

  @override
  String get noAccountSignup => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String loginFailed(Object error) {
    return 'Login failed: $error';
  }

  @override
  String signUpFailed(Object error) {
    return 'Sign up failed: $error';
  }

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get google => 'Google';

  @override
  String get facebook => 'Facebook';

  @override
  String get feed => 'Feed';

  @override
  String get discover => 'Discover';

  @override
  String get profile => 'Profile';

  @override
  String get inbox => 'Messages';

  @override
  String get addVideo => 'Add Video';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get followers => 'Followers';

  @override
  String get followingCount => 'Following';

  @override
  String get likes => 'Likes';

  @override
  String get comments => 'Comments';

  @override
  String get shares => 'Shares';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get share => 'Share';

  @override
  String get report => 'Report';

  @override
  String get block => 'Block';

  @override
  String get post => 'Post';

  @override
  String get posts => 'Posts';

  @override
  String get noPosts => 'No posts yet';

  @override
  String get createFirstPost => 'Create your first post!';

  @override
  String get loadingPosts => 'Loading posts...';

  @override
  String get errorLoadingPosts => 'Error loading posts';

  @override
  String get upload => 'Upload';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get liked => 'Liked';

  @override
  String get noUploadedVideos => 'No uploaded videos yet.';

  @override
  String get noLikedVideos => 'No liked videos yet.';

  @override
  String get pickVideo => 'Please select a video first';

  @override
  String get pickVideoButton => 'Pick Video';

  @override
  String get uploadVideoButton => 'Upload Video';

  @override
  String get addDescription => 'Add Video Description';

  @override
  String get videoUploadSuccess => 'Video uploaded successfully!';

  @override
  String videoUploadFailure(Object error) {
    return 'Failed to upload video: $error';
  }

  @override
  String errorPickingVideo(Object error) {
    return 'Error picking video: $error';
  }

  @override
  String get nologinupload => 'You must be logged in to upload a video.';

  @override
  String get videoTooLarge => 'Video file is too large (max 50MB)';

  @override
  String get uploading => 'Uploading...';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get blockUser => 'Block User';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get changeVideo => 'Change Video';

  @override
  String get bio => 'Bio';

  @override
  String get website => 'Website';

  @override
  String get phone => 'Phone';

  @override
  String get birthday => 'Birthday';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get nofollowers => 'No followers yet.';

  @override
  String get nofollowings => 'Not following anyone yet.';

  @override
  String get errorfollower => 'Error loading followers';

  @override
  String get errorfollowing => 'Error loading following';

  @override
  String failedfollow(Object error) {
    return 'Failed to: $error Please try again.';
  }

  @override
  String get account => 'Account';

  @override
  String get privacy => 'Privacy';

  @override
  String get help => 'Help';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get language => 'Language';

  @override
  String get notificationsSettings => 'Notifications';

  @override
  String get privacySettings => 'Privacy';

  @override
  String get security => 'Security';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get newemail => 'New Email';

  @override
  String get changeUsername => 'Change Username';

  @override
  String get newUsernameHint => 'Enter new username';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPasswordHint => 'Enter old password';

  @override
  String get newPasswordHint => 'Enter new password';

  @override
  String get confirmNewPasswordHint => 'Confirm new password';

  @override
  String get confirmPasswordHint => 'Confirm new password';

  @override
  String get noEmailSet => 'No email set.';

  @override
  String get dosenotMacth => 'Passwords do not match';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match.';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully.';

  @override
  String get usernameChangedSuccessfully => 'Username changed successfully.';

  @override
  String get confirmationEmailSent =>
      'Confirmation email sent. Please check your inbox.';

  @override
  String failedToChangeEmail(Object error) {
    return 'Failed to change email: $error';
  }

  @override
  String failedToChangeUsername(Object error) {
    return 'Failed to change username: $error';
  }

  @override
  String failedToChangePassword(Object error) {
    return 'Failed to change password: $error';
  }

  @override
  String get changeButton => 'Change';

  @override
  String get settingsButton => 'Settings';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deactivateAccount => 'Deactivate Account';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search users, videos...';

  @override
  String get searchM => 'Search Users Message';

  @override
  String get noResults => 'No results found';

  @override
  String get trending => 'Trending';

  @override
  String get forYou => 'For You';

  @override
  String get live => 'Live';

  @override
  String get comment => 'Comment';

  @override
  String get addComment => 'Add a comment';

  @override
  String get postComment => 'Post';

  @override
  String get reply => 'Reply';

  @override
  String viewReplies(Object count) {
    return 'View $count replies';
  }

  @override
  String get hideReplies => 'Hide replies';

  @override
  String get noComments => 'No comments yet.';

  @override
  String get beFirstComment => 'Be the first to comment';

  @override
  String failedToPostComment(Object error) {
    return 'Failed to post comment: $error';
  }

  @override
  String notificationLiked(Object username) {
    return '$username liked your video';
  }

  @override
  String notificationCommented(Object username) {
    return '$username commented on your video';
  }

  @override
  String notificationFollowed(Object username) {
    return '$username started following you';
  }

  @override
  String notificationShared(Object username) {
    return '$username shared your video';
  }

  @override
  String notificationMentioned(Object username) {
    return '$username mentioned you in a comment';
  }

  @override
  String get sendMessage => 'Type a message...';

  @override
  String get sendmessage => 'Send a Message';

  @override
  String get nomessages => 'No messages yet. Start a conversation!';

  @override
  String get defaultUsername => 'TikMe User';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get typing => 'typing...';

  @override
  String get deletemessages => 'Delete Message';

  @override
  String get deleteMesDes =>
      'Do you want to delete this message or all your messages in this conversation?';

  @override
  String get deleteAllmessages => 'Delete All My Messages';

  @override
  String get deletebutton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteCon => 'Delete All Conversations';

  @override
  String get deleteConDes =>
      'Are you sure you want to delete all conversations? This action cannot be undone.';

  @override
  String get selected => 'selected';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get camera => 'Camera';

  @override
  String get video => 'Video';

  @override
  String get document => 'Document';

  @override
  String get attachment => 'Attachment';

  @override
  String get image => 'Image';

  @override
  String get file => 'File';

  @override
  String get media => 'Media';

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String get profilePictureUpdated => 'Profile picture updated successfully!';

  @override
  String failedToUploadProfilePicture(Object error) {
    return 'Failed to upload profile picture: $error';
  }

  @override
  String get downloads => 'Downloads';

  @override
  String get noDownloads => 'No downloads yet';

  @override
  String get downloadCompleted => 'Download completed';

  @override
  String get completed => 'Completed';

  @override
  String get externalVideos => 'External Videos';

  @override
  String get pasteVideoUrl => 'Paste video URL';

  @override
  String get add => 'Add';

  @override
  String get noExternalVideos => 'No external videos';

  @override
  String get addVideoUrlsHint => 'Add YouTube, TikTok, Instagram video URLs';

  @override
  String get invalidVideoUrl => 'Invalid video URL';

  @override
  String get videoAdded => 'Video added successfully';

  @override
  String get cannotLaunchUrl => 'Cannot launch URL';

  @override
  String get supportedPlatforms => 'Supported Platforms';

  @override
  String get linkdownload => 'Link Download';

  @override
  String get deletevideo => 'Delete Video';

  @override
  String deletesure(Object fileName) {
    return 'Are you sure you want to delete \"$fileName\"?';
  }

  @override
  String deletesuccessfully(Object fileName) {
    return '\"$fileName\" deleted successfully';
  }

  @override
  String get deleteall => 'Delete All';

  @override
  String get deletealldownload => 'Delete All Downloads';

  @override
  String deletealldownloadsure(Object count) {
    return 'Are you sure you want to delete all $count downloaded videos? This action cannot be undone.';
  }

  @override
  String deletevideosuccessfully(Object count) {
    return '$count videos deleted successfully';
  }

  @override
  String get filelocation => 'File Location';

  @override
  String get storagereq => 'Storage Access Required';

  @override
  String get storagereqsure =>
      'To view and manage your downloaded videos, please allow storage access permission. This allows the app to access videos saved in your Movies folder.';

  @override
  String get grantpermission => 'Grant Permission';

  @override
  String get opensettings => 'Open App Settings';

  @override
  String get downloadtitel =>
      'Downloaded videos will appear here.\nVideos are saved to Movies/TikMe folder on your device.';

  @override
  String get location => 'Show in folder';

  @override
  String get loadingdownload => 'Loading downloads...';

  @override
  String get refresh => 'Refresh Downloads';

  @override
  String get videoPlayer => 'Video Player';

  @override
  String get documentSharing => 'Document Sharing';

  @override
  String get loadingvideo => 'Loading video...';

  @override
  String get videonotwork => 'The video file may be corrupted or unavailable';

  @override
  String get videofailed => 'Failed to load video';

  @override
  String get videonotavailable => 'Video not available';

  @override
  String get novideofound => 'No Video found';

  @override
  String get goback => 'Go Back';

  @override
  String get retry => 'Retry';

  @override
  String detailsScreenTitle(Object videoId) {
    return 'Video Details: $videoId';
  }

  @override
  String viewingVideoWithId(Object videoId) {
    return 'Viewing video with ID: $videoId';
  }

  @override
  String get videoTitleLabel => 'Title';

  @override
  String get videoDescriptionLabel => 'Video Description';

  @override
  String get noVideoSelected => 'No video selected.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pressAgainToExit => 'Press back again to exit';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get userNotFound => 'User not found';

  @override
  String failedToToggleFollow(Object error) {
    return 'Failed to toggle follow state: $error';
  }

  @override
  String get failedToUnfollow => 'Failed to unfollow. Please try again.';

  @override
  String get failedToFollow => 'Failed to follow. Please try again.';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPassword => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get usernameTaken => 'Username is already taken';

  @override
  String get emailInUse => 'Email is already in use';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get networkError => 'Network error, please try again';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get description => 'Description';

  @override
  String get close => 'close';
}
