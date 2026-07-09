// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'TikMe';

  @override
  String get appDescription => 'ከዓለም ዙሪያ የሚያምሩ ቪዲዮዎችን ያግኙ እና ያጋሩ።';

  @override
  String get aboutDescription =>
      'TikMe ከታዋቂ መድረኮች የተመሰረተ አጭር ቪዲዮ ማጋራት መተግበሪያ ነው። ተጠቃሚዎች አጭር ቪዲዮዎችን ሊጫኑ፣ ሊያዩ፣ ሊወዱ እና አስተያየት ሊሰጡ ይችላሉ። የተጠቃሚ ማረጋገጫ፣ የመገለጫ አስተዳደር እና ለእያንዳንዱ የተመጠነ ቪዲዮ ፊድ ያለው ነው።';

  @override
  String appVersion(Object version) {
    return 'የመተግበሪያ ስሪት: $version';
  }

  @override
  String get developedBy => 'የተሰራው በ: Jstech';

  @override
  String get contactUs => 'ያግኙን: metube-support@google.com';

  @override
  String get login => 'ግባ';

  @override
  String get signUp => 'ተመዝገብ';

  @override
  String get logout => 'ውጣ';

  @override
  String get emailHint => 'ኢሜልዎን ያስገቡ';

  @override
  String get passwordHint => 'የይለፍ ቃልዎን ያስገቡ';

  @override
  String get confirmPassword => 'የይለፍ ቃል አረጋግጥ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get username => 'የተጠቃሚ ስም';

  @override
  String get loginButton => 'ግባ';

  @override
  String get signupButton => 'መለያ ፍጠር';

  @override
  String get noAccountSignup => 'መለያ የሎትም? ተመዝገብ';

  @override
  String get alreadyHaveAccount => 'ቀድሞውኑ መለያ አሎት? ግባ';

  @override
  String get dontHaveAccount => 'መለያ የሎትም? ተመዝገብ';

  @override
  String loginFailed(Object error) {
    return 'መግባት አልተሳካም: $error';
  }

  @override
  String signUpFailed(Object error) {
    return 'ምዝገባ አልተሳካም: $error';
  }

  @override
  String get forgotPassword => 'የይለፍ ቃልዎን ረሱ?';

  @override
  String get orContinueWith => 'ወይም በ';

  @override
  String get google => 'ጉግል';

  @override
  String get facebook => 'ፌስቡክ';

  @override
  String get feed => 'ፊድ';

  @override
  String get discover => 'አግኝ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get inbox => 'መልዕክቶች';

  @override
  String get addVideo => 'ቪዲዮ ጨምር';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get about => 'ስለ';

  @override
  String get follow => 'ተከተል';

  @override
  String get following => 'በመከተል ላይ';

  @override
  String get unfollow => 'አቁም መከተል';

  @override
  String get followers => 'ተከታታዮች';

  @override
  String get followingCount => 'በመከተል ላይ';

  @override
  String get likes => 'ውዴዎች';

  @override
  String get comments => 'አስተያየቶች';

  @override
  String get shares => 'ማጋራቶች';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get saved => 'ተቀምጧል';

  @override
  String get share => 'አጋራ';

  @override
  String get report => 'ሪፖርት አድርግ';

  @override
  String get block => 'አግድ';

  @override
  String get post => 'ልጥፍ';

  @override
  String get posts => 'ልጥፎች';

  @override
  String get noPosts => 'እስካሁን ምንም ልጥፎች የሉም';

  @override
  String get createFirstPost => 'የመጀመሪያ ልጥፍዎን ይፍጠሩ!';

  @override
  String get loadingPosts => 'ልጥፎች በመጫን ላይ...';

  @override
  String get errorLoadingPosts => 'ልጥፎችን በማጫን ላይ ስህተት ተከስቷል';

  @override
  String get upload => 'ጫን';

  @override
  String get uploaded => 'ተጫኗል';

  @override
  String get liked => 'ተወድቋል';

  @override
  String get noUploadedVideos => 'እስካሁን ምንም የተጫኑ ቪዲዮዎች የሉም።';

  @override
  String get noLikedVideos => 'እስካሁን ምንም የወደዱ ቪዲዮዎች የሉም።';

  @override
  String get pickVideo => 'እባክዎ መጀመሪያ ቪዲዮ ይምረጡ';

  @override
  String get pickVideoButton => 'ቪዲዮ ይምረጡ';

  @override
  String get uploadVideoButton => 'ቪዲዮ ጫን';

  @override
  String get addDescription => 'የቪዲዮ መግለጫ ጨምር';

  @override
  String get videoUploadSuccess => 'ቪዲዮው በተሳካ ሁኔታ ተጫኗል!';

  @override
  String videoUploadFailure(Object error) {
    return 'ቪዲዮ መጫን አልተሳካም: $error';
  }

  @override
  String errorPickingVideo(Object error) {
    return 'ቪዲዮ በማምረጥ ላይ ስህተት: $error';
  }

  @override
  String get nologinupload => 'ቪዲዮ ለመጫን መግባት አለብዎት።';

  @override
  String get videoTooLarge => 'የቪዲዮ ፋይሉ በጣም ትልቅ ነው (ከፍተኛው 50MB)';

  @override
  String get uploading => 'በመጫን ላይ...';

  @override
  String get viewProfile => 'መገለጫ ይመልከቱ';

  @override
  String get editProfile => 'መገለጫ አርትዕ';

  @override
  String get blockUser => 'ተጠቃሚ አግድ';

  @override
  String get changePhoto => 'ፎቶ ቀይር';

  @override
  String get changeVideo => 'ቪዲዮ ቀይር';

  @override
  String get bio => 'ባዮ';

  @override
  String get website => 'ድር ጣቢያ';

  @override
  String get phone => 'ስልክ';

  @override
  String get birthday => 'የልደት ቀን';

  @override
  String get gender => 'ጾታ';

  @override
  String get male => 'ወንድ';

  @override
  String get female => 'ሴት';

  @override
  String get other => 'ሌላ';

  @override
  String get nofollowers => 'እስካሁን ምንም ተከታታዮች የሉም።';

  @override
  String get nofollowings => 'እስካሁን ማንንም አልተከተሉም።';

  @override
  String get errorfollower => 'ተከታታዮችን በማጫን ላይ ስህተት';

  @override
  String get errorfollowing => 'በመከተል ላይ ያሉትን በማጫን ላይ ስህተት';

  @override
  String failedfollow(Object error) {
    return 'አልተሳካም: $error እባክዎ እንደገና ይሞክሩ።';
  }

  @override
  String get account => 'መለያ';

  @override
  String get privacy => 'ግላዊነት';

  @override
  String get help => 'እርዳታ';

  @override
  String get darkMode => 'ጨለማ ሞድ';

  @override
  String get lightMode => 'ብርሀን ሞድ';

  @override
  String get systemTheme => 'የስርዓት ገጽታ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get notificationsSettings => 'ማሳወቂያዎች';

  @override
  String get privacySettings => 'ግላዊነት';

  @override
  String get security => 'ደህንነት';

  @override
  String get helpCenter => 'የእርዳታ ማዕከል';

  @override
  String get termsOfService => 'የአገልግሎት ውሎች';

  @override
  String get privacyPolicy => 'የግላዊነት ፖሊሲ';

  @override
  String get changeEmail => 'ኢሜል ቀይር';

  @override
  String get newemail => 'አዲስ ኢሜል';

  @override
  String get changeUsername => 'የተጠቃሚ ስም ቀይር';

  @override
  String get newUsernameHint => 'አዲስ የተጠቃሚ ስም ያስገቡ';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get oldPasswordHint => 'የድሮ የይለፍ ቃል ያስገቡ';

  @override
  String get newPasswordHint => 'አዲስ የይለፍ ቃል ያስገቡ';

  @override
  String get confirmNewPasswordHint => 'አዲሱን የይለፍ ቃል አረጋግጥ';

  @override
  String get confirmPasswordHint => 'የይለፍ ቃል አረጋግጥ';

  @override
  String get noEmailSet => 'ኢሜል አልተዘጋጀም።';

  @override
  String get dosenotMacth => 'የይለፍ ቃላቶቹ አይጣጣሙም';

  @override
  String get newPasswordsDoNotMatch => 'አዲሶቹ የይለፍ ቃላት አይጣጣሙም።';

  @override
  String get passwordChangedSuccessfully => 'የይለፍ ቃሉ በተሳካ ሁኔታ ተቀይሯል።';

  @override
  String get usernameChangedSuccessfully => 'የተጠቃሚ ስሙ በተሳካ ሁኔታ ተቀይሯል።';

  @override
  String get confirmationEmailSent =>
      'የማረጋገጫ ኢሜል ተልኳል። እባክዎ የገቢ መልዕክት ሳጥንዎን ያረጋግጡ።';

  @override
  String failedToChangeEmail(Object error) {
    return 'ኢሜል መቀየር አልተሳካም: $error';
  }

  @override
  String failedToChangeUsername(Object error) {
    return 'የተጠቃሚ ስም መቀየር አልተሳካም: $error';
  }

  @override
  String failedToChangePassword(Object error) {
    return 'የይለፍ ቃል መቀየር አልተሳካም: $error';
  }

  @override
  String get changeButton => 'ቀይር';

  @override
  String get settingsButton => 'ቅንብሮች';

  @override
  String get deleteAccount => 'መለያ ሰርዝ';

  @override
  String get deactivateAccount => 'መለያ አቦዝን';

  @override
  String get search => 'ፈልግ';

  @override
  String get searchHint => 'ተጠቃሚዎችን፣ ቪዲዮዎችን ፈልግ...';

  @override
  String get searchM => 'የተጠቃሚ መልዕክቶችን ፈልግ';

  @override
  String get noResults => 'ምንም ውጤቶች አልተገኙም';

  @override
  String get trending => 'ታዋቂ';

  @override
  String get forYou => 'ለአንተ';

  @override
  String get live => 'ቀጥታ';

  @override
  String get comment => 'አስተያየት';

  @override
  String get addComment => 'አስተያየት ጨምር';

  @override
  String get postComment => 'ልጥፍ';

  @override
  String get reply => 'መልስ';

  @override
  String viewReplies(Object count) {
    return '$count መልሶች ይመልከቱ';
  }

  @override
  String get hideReplies => 'መልሶችን ደብቅ';

  @override
  String get noComments => 'እስካሁን ምንም አስተያየቶች የሉም።';

  @override
  String get beFirstComment => 'አስተያየት ለመስጠት የመጀመሪያ ይሁኑ';

  @override
  String failedToPostComment(Object error) {
    return 'አስተያየት ለመለጠፍ አልተሳካም: $error';
  }

  @override
  String notificationLiked(Object username) {
    return '$username ቪዲዮዎን ወደዱ';
  }

  @override
  String notificationCommented(Object username) {
    return '$username በቪዲዮዎ ላይ አስተያየት ሰጡ';
  }

  @override
  String notificationFollowed(Object username) {
    return '$username እየተከተሉዎ ነው';
  }

  @override
  String notificationShared(Object username) {
    return '$username ቪዲዮዎን አጋሩ';
  }

  @override
  String notificationMentioned(Object username) {
    return '$username በአስተያየት አጠቃሎ ጠቅሰዎታል';
  }

  @override
  String get sendMessage => 'መልዕክት ይጻፉ...';

  @override
  String get sendmessage => 'መልዕክት ላክ';

  @override
  String get nomessages => 'እስካሁን ምንም መልዕክቶች የሉም። ውይይት ይጀምሩ!';

  @override
  String get defaultUsername => 'የTikMe ተጠቃሚ';

  @override
  String get online => 'በመስመር ላይ';

  @override
  String get offline => 'ከመስመር ውጭ';

  @override
  String get typing => 'በመጻፍ ላይ...';

  @override
  String get deletemessages => 'መልዕክት ሰርዝ';

  @override
  String get deleteMesDes =>
      'ይህን መልዕክት ወይም በዚህ ውይይት ውስጥ ያሉትን ሁሉንም መልዕክቶችዎን ማስወገድ ይፈልጋሉ?';

  @override
  String get deleteAllmessages => 'ሁሉንም መልዕክቶቼን ሰርዝ';

  @override
  String get deletebutton => 'ሰርዝ';

  @override
  String get cancelButton => 'ተወ';

  @override
  String get deleteCon => 'ሁሉንም ውይይቶች ሰርዝ';

  @override
  String get deleteConDes =>
      'ሁሉንም ውይይቶች ማስወገድ እንደሚፈልጉ እርግጠኛ ነዎት? ይህ እርምጃ መመለስ አይችልም።';

  @override
  String get selected => 'ተመርጧል';

  @override
  String get photoLibrary => 'የፎቶ ቤተ መጻሕፍት';

  @override
  String get camera => 'ካሜራ';

  @override
  String get video => 'ቪዲዮ';

  @override
  String get document => 'ሰነድ';

  @override
  String get attachment => 'ተቆራኝ';

  @override
  String get image => 'ምስል';

  @override
  String get file => 'ፋይል';

  @override
  String get media => 'ሚዲያ';

  @override
  String errorPickingImage(Object error) {
    return 'ምስል በማምረጥ ላይ ስህተት: $error';
  }

  @override
  String get profilePictureUpdated => 'የመገለጫ ፎቶ በተሳካ ሁኔታ ተዘምኗል!';

  @override
  String failedToUploadProfilePicture(Object error) {
    return 'የመገለጫ ፎቶ መጫን አልተሳካም: $error';
  }

  @override
  String get downloads => 'የተጫኑ';

  @override
  String get noDownloads => 'እስካሁን ምንም የተጫኑ የሉም';

  @override
  String get downloadCompleted => 'መጫኑ ተጠናቅቋል';

  @override
  String get completed => 'ተጠናቅቋል';

  @override
  String get externalVideos => 'የውጭ ቪዲዮዎች';

  @override
  String get pasteVideoUrl => 'የቪዲዮ URL አስገባ';

  @override
  String get add => 'ጨምር';

  @override
  String get noExternalVideos => 'የውጭ ቪዲዮዎች የሉም';

  @override
  String get addVideoUrlsHint => 'YouTube፣ TikTok፣ Instagram የቪዲዮ URLዎችን ጨምር';

  @override
  String get invalidVideoUrl => 'ልክ ያልሆነ የቪዲዮ URL';

  @override
  String get videoAdded => 'ቪዲዮው በተሳካ ሁኔታ ጨመረ';

  @override
  String get cannotLaunchUrl => 'URL ማስፈጸም አይቻልም';

  @override
  String get supportedPlatforms => 'የሚደገፉ መድረኮች';

  @override
  String get linkdownload => 'በማገናኛ ማውረድ';

  @override
  String get deletevideo => 'ቪዲዮ ሰርዝ';

  @override
  String deletesure(Object fileName) {
    return '\"$fileName\" ማስወገድ እንደሚፈልጉ እርግጠኛ ነዎት?';
  }

  @override
  String deletesuccessfully(Object fileName) {
    return '\"$fileName\" በተሳካ ሁኔታ ተሰርዟል';
  }

  @override
  String get deleteall => 'ሁሉንም ሰርዝ';

  @override
  String get deletealldownload => 'ሁሉንም የተጫኑትን ሰርዝ';

  @override
  String deletealldownloadsure(Object count) {
    return 'ሁሉንም $count የተጫኑ ቪዲዮዎች ማስወገድ እንደሚፈልጉ እርግጠኛ ነዎት? ይህ እርምጃ መመለስ አይችልም።';
  }

  @override
  String deletevideosuccessfully(Object count) {
    return '$count ቪዲዮ በተሳካ ሁኔታ ተሰርዟል';
  }

  @override
  String get filelocation => 'የፋይል ቦታ';

  @override
  String get storagereq => 'የማከማቻ መዳረሻ ፍቃድ ያስፈልጋል';

  @override
  String get storagereqsure =>
      'የተጫኑ ቪዲዮዎችዎን ለማየት እና ለማስተዳደር፣ እባክዎ የማከማቻ መዳረሻ ፍቃድ ይስጡ። ይህ መተግበሪያው በመሳሪያዎ ላይ በMovies ፎልደር ውስጥ የተቀመጡ ቪዲዮዎችን እንዲደርስ ይፈቅድለታል።';

  @override
  String get grantpermission => 'ፍቃድ ስጥ';

  @override
  String get opensettings => 'የመተግበሪያ ቅንብሮች ክፈት';

  @override
  String get downloadtitel =>
      'የተጫኑ ቪዲዮዎች እዚህ ይታያሉ።\nቪዲዮዎች በመሳሪያዎ ላይ በMovies/TikMe ፎልደር ውስጥ ይቀመጣሉ።';

  @override
  String get location => 'በፎልደር ውስጥ አሳይ';

  @override
  String get loadingdownload => 'የተጫኑት በመጫን ላይ...';

  @override
  String get refresh => 'የተጫኑትን አድስ';

  @override
  String get videoPlayer => 'የቪዲዮ ማጫወቻ';

  @override
  String get documentSharing => 'የሰነድ ማጋራት';

  @override
  String get loadingvideo => 'ቪዲዮ በመጫን ላይ...';

  @override
  String get videonotwork => 'የቪዲዮ ፋይሉ የተበላሸ ሊሆን ይችላል ወይም አይገኝም';

  @override
  String get videofailed => 'ቪዲዮ መጫን አልተሳካም';

  @override
  String get videonotavailable => 'ቪዲዮ አይገኝም';

  @override
  String get novideofound => 'ቪዲዮ አልተገኘም';

  @override
  String get goback => 'ተመለስ';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String detailsScreenTitle(Object videoId) {
    return 'የቪዲዮ ዝርዝሮች: $videoId';
  }

  @override
  String viewingVideoWithId(Object videoId) {
    return 'ቪዲዮ እየታየ ነው ከመለያ: $videoId';
  }

  @override
  String get videoTitleLabel => 'ርዕስ';

  @override
  String get videoDescriptionLabel => 'የቪዲዮ መግለጫ';

  @override
  String get noVideoSelected => 'ምንም ቪዲዮ አልተመረጠም።';

  @override
  String get yesterday => 'ትላንት';

  @override
  String get pressAgainToExit => 'ለመውጣት እንደገና ይጫኑ';

  @override
  String get noInternetConnection => 'የበይነመረብ ግንኙነት የለም';

  @override
  String error(Object error) {
    return 'ስህተት: $error';
  }

  @override
  String get userNotFound => 'ተጠቃሚ አልተገኘም';

  @override
  String failedToToggleFollow(Object error) {
    return 'የመከተል ሁኔታ መቀየር አልተሳካም: $error';
  }

  @override
  String get failedToUnfollow => 'መከተል ማቆም አልተሳካም። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get failedToFollow => 'መከተል አልተሳካም። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get invalidEmail => 'እባክዎ ትክክለኛ ኢሜል አስገቡ';

  @override
  String get invalidPassword => 'የይለፍ ቃሉ ቢያንስ 6 ፊደላት ሊኖሩት ይገባል';

  @override
  String get passwordsDontMatch => 'የይለፍ ቃላቶቹ አይጣጣሙም';

  @override
  String get usernameTaken => 'የተጠቃሚ ስሙ አስቀድሞ ተወስዷል';

  @override
  String get emailInUse => 'ኢሜሉ አስቀድሞ ተጠቅሟል';

  @override
  String get weakPassword => 'የይለፍ ቃሉ በጣም ደካማ ነው';

  @override
  String get wrongPassword => 'የይለፍ ቃሉ ስህተት ነው';

  @override
  String get networkError => 'የበይነመረብ ስህተት፣ እባክዎ እንደገና ይሞክሩ';

  @override
  String get unknownError => 'ያልታወቀ ስህተት ተከስቷል';

  @override
  String get description => 'መግለጫ';

  @override
  String get close => 'ዝጋ';
}
