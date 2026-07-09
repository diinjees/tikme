// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get appTitle => 'TikMe';

  @override
  String get appDescription =>
      'Helo oo la wadaag muusikyo cajiib ah adduunka oo dhan.';

  @override
  String get aboutDescription =>
      'TikMe waa barnaamij muusikyo gaagaaban oo laga soo waayay barnaamijyada caanka ah. Isticmaalayaashu waxay soo gelin karaan, daawadaan, jeclaadaan, oo faallo gelin karaan muusikyo gaagaaban. Waxay leedahay xaqiijin istcmaaleye, maareyn barnaamij, iyo muusikyo gaar ah.';

  @override
  String appVersion(Object version) {
    return 'Nooca Barnaamijka: $version';
  }

  @override
  String get developedBy => 'Waa la horumariyay: Jstech';

  @override
  String get contactUs => 'Nala soo xiriir: metube-support@google.com';

  @override
  String get login => 'Geli';

  @override
  String get signUp => 'Diiwaangeli';

  @override
  String get logout => 'Ka bax';

  @override
  String get emailHint => 'Geli iimaylkaaga';

  @override
  String get passwordHint => 'Geli eraygaaga sirta ah';

  @override
  String get confirmPassword => 'Xaqiiji erayga sirta ah';

  @override
  String get fullName => 'Magaca Oo Dhan';

  @override
  String get username => 'Magaca Isticmaalaha';

  @override
  String get loginButton => 'Geli';

  @override
  String get signupButton => 'Abuur Koonto';

  @override
  String get noAccountSignup => 'Ma haysataa koonto? Diiwaangeli';

  @override
  String get alreadyHaveAccount => 'Horey ma haysataa koonto? Geli';

  @override
  String get dontHaveAccount => 'Ma haysataa koonto? Diiwaangeli';

  @override
  String loginFailed(Object error) {
    return 'Khalad ayaa dhacay gelitaanka: $error';
  }

  @override
  String signUpFailed(Object error) {
    return 'Khalad ayaa dhacay diiwaangashada: $error';
  }

  @override
  String get forgotPassword => 'Ma ilowday eraygaaga sirta ah?';

  @override
  String get orContinueWith => 'Ama sii wad iyadoo';

  @override
  String get google => 'Google';

  @override
  String get facebook => 'Facebook';

  @override
  String get feed => 'Feed';

  @override
  String get discover => 'Hel';

  @override
  String get profile => 'Barnaamijka';

  @override
  String get inbox => 'Fariimaha';

  @override
  String get addVideo => 'Ku Dar Muusik';

  @override
  String get notifications => 'Ogeysiisyada';

  @override
  String get settings => 'Dejinta';

  @override
  String get about => 'Ku Saabsan';

  @override
  String get follow => 'Raac';

  @override
  String get following => 'Waa Raacay';

  @override
  String get unfollow => 'Ka noqo Raacitaanka';

  @override
  String get followers => 'Raacayaal';

  @override
  String get followingCount => 'Raacitaanka';

  @override
  String get likes => 'Jeclaan';

  @override
  String get comments => 'Faallooyin';

  @override
  String get shares => 'Wadaag';

  @override
  String get save => 'Kaydi';

  @override
  String get saved => 'La Kaydiyay';

  @override
  String get share => 'Wadaag';

  @override
  String get report => 'Warbixin';

  @override
  String get block => 'Xannibo';

  @override
  String get post => 'Boost';

  @override
  String get posts => 'Boostada';

  @override
  String get noPosts => 'Weli ma jiraan boosto';

  @override
  String get createFirstPost => 'Abuur boostadaada ugu horreysa!';

  @override
  String get loadingPosts => 'Boostada la soo dejiyayo...';

  @override
  String get errorLoadingPosts => 'Khalad ayaa dhacay soo dejinta boostada';

  @override
  String get upload => 'Soo Gelid';

  @override
  String get uploaded => 'La soo geliyay';

  @override
  String get liked => 'La jeclaaday';

  @override
  String get noUploadedVideos => 'Weli ma jiraan muusikyo la soo geliyay.';

  @override
  String get noLikedVideos => 'Weli ma jiraan muusikyo aad jeceshahay.';

  @override
  String get pickVideo => 'Fadlan dooro muusik marka hore';

  @override
  String get pickVideoButton => 'Dooro Muusik';

  @override
  String get uploadVideoButton => 'Soo Geli Muusik';

  @override
  String get addDescription => 'Ku Dar Sharaxaadda Muusika';

  @override
  String get videoUploadSuccess => 'Muusikii si guul leh ayaa loo soo geliyay!';

  @override
  String videoUploadFailure(Object error) {
    return 'Khalad ayaa dhacay soo gelinta muusika: $error';
  }

  @override
  String errorPickingVideo(Object error) {
    return 'Khalad ayaa dhacay doorashada muusika: $error';
  }

  @override
  String get nologinupload =>
      'Waa inaad geli kartaa si aad muusik u soo gasho.';

  @override
  String get videoTooLarge =>
      'Faylka muusikuu aad u weyn yahay (ugu badan 50MB)';

  @override
  String get uploading => 'La soo gelinayo...';

  @override
  String get viewProfile => 'Eeg Barnaamijka';

  @override
  String get editProfile => 'Wax Ka Badal Barnaamijka';

  @override
  String get blockUser => 'Xannibo Isticmaale';

  @override
  String get changePhoto => 'Beddel Sawirka';

  @override
  String get changeVideo => 'Beddel Muusika';

  @override
  String get bio => 'Taariikh Nololeed';

  @override
  String get website => 'Website';

  @override
  String get phone => 'Taleefoon';

  @override
  String get birthday => 'Dhalashada';

  @override
  String get gender => 'Jinsiga';

  @override
  String get male => 'Lab';

  @override
  String get female => 'Dheddig';

  @override
  String get other => 'Kale';

  @override
  String get nofollowers => 'Weli ma jiraan raacayaal.';

  @override
  String get nofollowings => 'Weli ma raacinin qof.';

  @override
  String get errorfollower => 'Khalad ayaa dhacay soo dejinta raacayaasha';

  @override
  String get errorfollowing => 'Khalad ayaa dhacay soo dejinta raacitaanka';

  @override
  String failedfollow(Object error) {
    return 'Khalad ayaa dhacay: $error Fadlan isku day mar kale.';
  }

  @override
  String get account => 'Koonta';

  @override
  String get privacy => 'Qarsoodi';

  @override
  String get help => 'Gargaar';

  @override
  String get darkMode => 'Moodka Mugdiga';

  @override
  String get lightMode => 'Moodka Iftiinka';

  @override
  String get systemTheme => 'Moodka Nidaamka';

  @override
  String get language => 'Luqadda';

  @override
  String get notificationsSettings => 'Ogeysiisyada';

  @override
  String get privacySettings => 'Qarsoonida';

  @override
  String get security => 'Amniga';

  @override
  String get helpCenter => 'Xarunta Gargaarka';

  @override
  String get termsOfService => 'Shuruudaha Adeegga';

  @override
  String get privacyPolicy => 'Qaanuunka Qarsoonida';

  @override
  String get changeEmail => 'Beddel Iimaylka';

  @override
  String get newemail => 'Iimayl Cusub';

  @override
  String get changeUsername => 'Beddel Magaca Isticmaalaha';

  @override
  String get newUsernameHint => 'Geli magac cusub';

  @override
  String get changePassword => 'Beddel Erayga Sirta Ah';

  @override
  String get oldPasswordHint => 'Geli eraygii hore ee sirta ah';

  @override
  String get newPasswordHint => 'Geli eray cusub ee sirta ah';

  @override
  String get confirmNewPasswordHint => 'Xaqiiji erayga cusub ee sirta ah';

  @override
  String get confirmPasswordHint => 'Xaqiiji erayga sirta ah';

  @override
  String get noEmailSet => 'Iimayl ma la dejiyin.';

  @override
  String get dosenotMacth => 'Erayada sirta ah ma qabanay';

  @override
  String get newPasswordsDoNotMatch => 'Erayada cusub ee sirta ah ma qabanay.';

  @override
  String get passwordChangedSuccessfully =>
      'Erayga sirta ah si guul leh ayaa loo beddelay.';

  @override
  String get usernameChangedSuccessfully =>
      'Magaca istcmaalaha si guul leh ayaa loo beddelay.';

  @override
  String get confirmationEmailSent =>
      'Iimayl xaqiijin ayaa la soo diray. Fadlan hubi sanduuqaaga.';

  @override
  String failedToChangeEmail(Object error) {
    return 'Khalad ayaa dhacay bedelka iimaylka: $error';
  }

  @override
  String failedToChangeUsername(Object error) {
    return 'Khalad ayaa dhacay bedelka magaca: $error';
  }

  @override
  String failedToChangePassword(Object error) {
    return 'Khalad ayaa dhacay bedelka erayga sirta ah: $error';
  }

  @override
  String get changeButton => 'Beddel';

  @override
  String get settingsButton => 'Dejinta';

  @override
  String get deleteAccount => 'Tirtir Koonta';

  @override
  String get deactivateAccount => 'Ha Aktivayn Koonta';

  @override
  String get search => 'Raadi';

  @override
  String get searchHint => 'Raadi isticmaalayaal, muusikyo...';

  @override
  String get searchM => 'Raadi Fariimaha Isticmaalayaasha';

  @override
  String get noResults => 'Lama helin natiijooyin';

  @override
  String get trending => 'Caanka Ah';

  @override
  String get forYou => 'Kuugu Khaas';

  @override
  String get live => 'Toggaan';

  @override
  String get comment => 'Faallo';

  @override
  String get addComment => 'Ku dar faallo';

  @override
  String get postComment => 'Boost';

  @override
  String get reply => 'Jawaab';

  @override
  String viewReplies(Object count) {
    return 'Eeg $count jawaab';
  }

  @override
  String get hideReplies => 'Qari jawaabaha';

  @override
  String get noComments => 'Weli ma jiraan faallooyin.';

  @override
  String get beFirstComment => 'Noqo midkii ugu horreeyey ee faallo geliya';

  @override
  String failedToPostComment(Object error) {
    return 'Khalad ayaa dhacay boostinta faallada: $error';
  }

  @override
  String notificationLiked(Object username) {
    return '$username wuxuu jeclaaday muusikaaga';
  }

  @override
  String notificationCommented(Object username) {
    return '$username wuxuu faallo geliyay muusikaaga';
  }

  @override
  String notificationFollowed(Object username) {
    return '$username wuxuu ku raacay';
  }

  @override
  String notificationShared(Object username) {
    return '$username wuxuu wadaagay muusikaaga';
  }

  @override
  String notificationMentioned(Object username) {
    return '$username wuxuu ku xusay faallada';
  }

  @override
  String get sendMessage => 'Qor fariin...';

  @override
  String get sendmessage => 'Dir Fariin';

  @override
  String get nomessages => 'Weli ma jiraan fariimmo. Bilow wada hadal!';

  @override
  String get defaultUsername => 'Isticmaale TikMe';

  @override
  String get online => 'Khadka Tooska Ah';

  @override
  String get offline => 'Khadka La\'aan';

  @override
  String get typing => 'qoraya...';

  @override
  String get deletemessages => 'Tirtir Fariinta';

  @override
  String get deleteMesDes =>
      'Ma dooneysaa inaad tirtirto fariintan ama dhammaan fariimahaada wada hadalkan?';

  @override
  String get deleteAllmessages => 'Tirtir Dhammaan Fariimahayga';

  @override
  String get deletebutton => 'Tirtir';

  @override
  String get cancelButton => 'Jooji';

  @override
  String get deleteCon => 'Tirtir Dhammaan Wada Hadalada';

  @override
  String get deleteConDes =>
      'Ma hubtaa inaad rabto inaad tirtirto dhammaan wada hadalada? Tallaabadan dib looma celin karo.';

  @override
  String get selected => 'la doortay';

  @override
  String get photoLibrary => 'Maktabadda Sawirka';

  @override
  String get camera => 'Kaamera';

  @override
  String get video => 'Muusik';

  @override
  String get document => 'Dukumiinti';

  @override
  String get attachment => 'Lifaaq';

  @override
  String get image => 'Sawir';

  @override
  String get file => 'Fayl';

  @override
  String get media => 'Warbaahin';

  @override
  String errorPickingImage(Object error) {
    return 'Khalad ayaa dhacay doorashada sawirka: $error';
  }

  @override
  String get profilePictureUpdated =>
      'Sawirka barnaamijka si guul leh ayaa loo cusboonaysiiyay!';

  @override
  String failedToUploadProfilePicture(Object error) {
    return 'Khalad ayaa dhacay soo gelinta sawirka barnaamijka: $error';
  }

  @override
  String get downloads => 'Soo Dejinta';

  @override
  String get noDownloads => 'Weli ma jiraan soo dejis';

  @override
  String get downloadCompleted => 'Soo dejintii waa la dhammaystiray';

  @override
  String get completed => 'La Dhammaystiriray';

  @override
  String get externalVideos => 'Muusikyada Dibadda';

  @override
  String get pasteVideoUrl => 'Dhig URL-ka muusika';

  @override
  String get add => 'Ku Dar';

  @override
  String get noExternalVideos => 'Ma jiraan muusikyo dibedda ah';

  @override
  String get addVideoUrlsHint =>
      'Ku dar YouTube, TikTok, Instagram URL-yada muusika';

  @override
  String get invalidVideoUrl => 'URL-ka muusikuu khalad yahay';

  @override
  String get videoAdded => 'Muusikii si guul leh ayaa loogu daray';

  @override
  String get cannotLaunchUrl => 'URL-ka lama furay';

  @override
  String get supportedPlatforms => 'Platform-yada La Taageero';

  @override
  String get linkdownload => 'Soo Dejin Xiriir';

  @override
  String get deletevideo => 'Tirtir Muusika';

  @override
  String deletesure(Object fileName) {
    return 'Ma hubtaa inaad rabto inaad tirtirto \"$fileName\"?';
  }

  @override
  String deletesuccessfully(Object fileName) {
    return '\"$fileName\" si guul leh ayaa loo tirtiray';
  }

  @override
  String get deleteall => 'Tirtir Dhammaan';

  @override
  String get deletealldownload => 'Tirtir Dhammaan Soo Dejinta';

  @override
  String deletealldownloadsure(Object count) {
    return 'Ma hubtaa inaad rabto inaad tirtirto dhammaan $count muusikyada la soo dejistay? Tallaabadan dib looma celin karo.';
  }

  @override
  String deletevideosuccessfully(Object count) {
    return '$count muusik si guul leh ayaa loo tirtiray';
  }

  @override
  String get filelocation => 'Goobta Faylka';

  @override
  String get storagereq =>
      'Ogolaanshaha Helitaanka Kaydka ayaa Loo Baahan Yahay';

  @override
  String get storagereqsure =>
      'Si aad u aragto oo maamusho muusikyadaada la soo dejistay, fadlan ogolaansho helitaanka kaydka. Tani waxay u ogolaanaysaa barnaamijka inuu helo muusikyada la kaydiyay galkaaga Movies.';

  @override
  String get grantpermission => 'Si Ogolaansho';

  @override
  String get opensettings => 'Fur Dejinta Barnaamijka';

  @override
  String get downloadtitel =>
      'Muusikyada la soo dejistay halkan ayay ku soo baxayaan.\nMuusikyada waxaa lagu kaydinayaa galka Movies/TikMe ee qalabkaaga.';

  @override
  String get location => 'Tus galka';

  @override
  String get loadingdownload => 'Soo dejinta la soo dejiyayo...';

  @override
  String get refresh => 'Dib U Cusboonaysii Soo Dejinta';

  @override
  String get videoPlayer => 'Daawadaha Muusika';

  @override
  String get documentSharing => 'Wadaagista Dukumiintiga';

  @override
  String get loadingvideo => 'Muusik la soo dejiyayo...';

  @override
  String get videonotwork => 'Faylka muusikuu xumaan yahay ama lama heli karo';

  @override
  String get videofailed => 'Khalad ayaa dhacay soo dejinta muusika';

  @override
  String get videonotavailable => 'Muusik lama heli karo';

  @override
  String get novideofound => 'Lama helin Muusik';

  @override
  String get goback => 'Dib U Noqo';

  @override
  String get retry => 'Isku Day Mar Kale';

  @override
  String detailsScreenTitle(Object videoId) {
    return 'Faahfaahinta Muusika: $videoId';
  }

  @override
  String viewingVideoWithId(Object videoId) {
    return 'Daawashada muusika leh Aqoonsiga: $videoId';
  }

  @override
  String get videoTitleLabel => 'Cinwaanka';

  @override
  String get videoDescriptionLabel => 'Sharaxaadda Muusika';

  @override
  String get noVideoSelected => 'Lama dooran Muusik.';

  @override
  String get yesterday => 'Shalay';

  @override
  String get pressAgainToExit => 'Riix mar kale si aad uga baxdo';

  @override
  String get noInternetConnection => 'Xidhiidh internet ah ma jiro';

  @override
  String error(Object error) {
    return 'Khalad: $error';
  }

  @override
  String get userNotFound => 'Isticmaale lama helin';

  @override
  String failedToToggleFollow(Object error) {
    return 'Khalad ayaa dhacay bedelka xaaladda raacitaanka: $error';
  }

  @override
  String get failedToUnfollow =>
      'Khalad ayaa dhacay ka noqoshada raacitaanka. Fadlan isku day mar kale.';

  @override
  String get failedToFollow =>
      'Khalad ayaa dhacay raacitaanka. Fadlan isku day mar kale.';

  @override
  String get invalidEmail => 'Fadlan geli cinwaan iimayl sax ah';

  @override
  String get invalidPassword => 'Erayga sirta ah waa inuu ka yaraan 6 xaraf';

  @override
  String get passwordsDontMatch => 'Erayada sirta ah ma qabanay';

  @override
  String get usernameTaken => 'Magaca istcmaalaha horey ayaa loo qaatay';

  @override
  String get emailInUse => 'Iimaylka horey ayaa loo isticmaalay';

  @override
  String get weakPassword => 'Erayga sirta ah aad buu u dhib yahay';

  @override
  String get wrongPassword => 'Erayga sirta ahuu khalad yahay';

  @override
  String get networkError => 'Khalad shabakad, fadlan isku day mar kale';

  @override
  String get unknownError => 'Khalad aan la aqoon ayaa dhacay';

  @override
  String get description => 'Sharaxaad';

  @override
  String get close => 'Xidh';
}
