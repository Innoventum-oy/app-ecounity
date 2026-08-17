// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get about => 'Tietoja';

  @override
  String get age => 'Ikä';

  @override
  String get account => 'Tili';

  @override
  String get achievements => 'Saavutukset';

  @override
  String get answer_saved => 'Vastaus tallennettu';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Huomio';

  @override
  String get authenticating => 'Autentikointi...';

  @override
  String get badge => 'Ansiomerkki';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Olet suorittanut $completed tähän ansiomerkkiin vaadittavista $required oppimissisällöstä.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Tämä ansiomerkki myönnetään, kun olet suorittanut kaikki oppitunnit ja haasteet $pathway polulla.';
  }

  @override
  String get button_accept => 'Hyväksy';

  @override
  String get button_approve => 'Hyväksy';

  @override
  String get badge_awarded => 'Uusi ansiomerkki ansaittu';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Onneksi olkoon, olet ansainnut $badge -ansiomerkin!';
  }

  @override
  String get button_back => 'Takaisin';

  @override
  String get button_cancel => 'Peruuta';

  @override
  String get button_close => 'Sulje';

  @override
  String get button_confirm => 'Vahvista';

  @override
  String get button_continue => 'Jatka';

  @override
  String get button_continue_as_guest => 'Jatka vieraana';

  @override
  String get button_create => 'Luo';

  @override
  String get button_create_account => 'Luo tili';

  @override
  String get button_delete => 'Poista';

  @override
  String get button_edit => 'Muokkaa';

  @override
  String get button_finish => 'Valmis';

  @override
  String get button_forgot_password => 'Unohditko salasanasi?';

  @override
  String get button_login => 'Kirjaudu sisään';

  @override
  String get button_logout => 'Kirjaudu ulos';

  @override
  String get button_next => 'Seuraava';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Edellinen';

  @override
  String get button_register => 'Rekisteröidy';

  @override
  String get button_reject => 'Hylkää';

  @override
  String get button_save => 'Tallenna';

  @override
  String get button_send => 'Lähetä';

  @override
  String get button_submit => 'Lähetä';

  @override
  String get cancel => 'Peruuta';

  @override
  String get choose_language => 'Valitse kieli';

  @override
  String get collected_badges => 'Kerätyt merkit';

  @override
  String get completed => 'Suoritettu';

  @override
  String get confirm_deleting_account =>
      'Oletko varma, että haluat poistaa tilisi?';

  @override
  String get contact => 'Ota yhteyttä';

  @override
  String get delete_account => 'Poista tili';

  @override
  String get email => 'Sähköposti';

  @override
  String get email_not_valid => 'Annettu sähköpostiosoite ei ole kelvollinen';

  @override
  String get email_or_phone_number => 'Sähköposti tai puhelinnumero';

  @override
  String error(String error) {
    return 'Virhe: $error';
  }

  @override
  String get error_default => 'Pyyntöä ei voitu suorittaa';

  @override
  String get error_occurred => 'Tapahtui virhe';

  @override
  String errorViewNotFound(String view) {
    return 'Näkymää $view ei löytynyt';
  }

  @override
  String get errors_in_form => 'Täytä kaikki pakolliset kentät';

  @override
  String field_required(String field) {
    return 'Kenttä $field on pakollinen';
  }

  @override
  String get firstName => 'Etunimi';

  @override
  String get funding_disclaimer =>
      'Euroopan unionin rahoittama. Esitetyt näkemykset ja mielipiteet ovat ainoastaan tämän tekstin laatijoiden näkemyksiä eivätkä välttämättä vastaa Euroopan unionin tai Euroopan koulutuksen ja kulttuurin toimeenpanovirasto (EACEA) kantaa. Euroopan unioni ja EACEA eivät ole vastuussa niistä.';

  @override
  String get great => 'Hienoa';

  @override
  String get home => 'Koti';

  @override
  String get introduction => 'Johdanto';

  @override
  String get language => 'Kieli';

  @override
  String get select_language => 'Valitse kieli';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'fi': 'Suomi',
      'en': 'Englanti',
      'it': 'Italia',
      'pt': 'Portugali',
      'pl': 'Puola',
      'de': 'Saksa',
      'uk': 'Ukraina',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Kieli:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Sukunimi';

  @override
  String get loading => 'Ladataan...';

  @override
  String get login => 'Kirjaudu sisään';

  @override
  String get login_failed => 'Kirjautuminen epäonnistui';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get logout_confirmation => 'Oletko varma, että haluat kirjautua ulos?';

  @override
  String get markAsCompleted => 'Merkitse suoritetuksi';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Koti',
      'pathways': 'Polut',
      'challenges': 'Haasteet',
      'videolist': 'Videot',
      'selfReflectionHub': 'Itsearviointikeskus',
      'lessons': 'Oppitunnit',
      'modules': 'Moduulit',
      'resources': 'Resurssit',
      'other': 'Valikko:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Seuraava';

  @override
  String get noBadgesFound => 'Ansiomerkkejä ei löytynyt';

  @override
  String get noChallengesFound => 'Haasteita ei löytynyt';

  @override
  String get noContentFound => 'Sisältöä ei löytynyt';

  @override
  String get noPathwaysFound => 'Oppimissisältöjä ei löytynyt';

  @override
  String get noTranscriptAvailable => 'Transkriptiä ei ole saatavilla';

  @override
  String get noVideosFound => 'Videoita ei löytynyt';

  @override
  String get noLessonsFound => 'Oppitunteja ei löytynyt';

  @override
  String get page_content => 'Sivun sisältö';

  @override
  String get password => 'Salasana';

  @override
  String get pathway => 'Oppimissisältö';

  @override
  String get pathway_already_completed => 'Oppimissisältö on jo suoritettu';

  @override
  String get pathway_completed => 'Oppimissisältö suoritettu';

  @override
  String get phone => 'Puhelin';

  @override
  String get phone_or_email => 'Puhelinnumero tai sähköpostiosoite';

  @override
  String get please_complete_form_properly => 'Täytä lomake oikein';

  @override
  String get please_enter_password => 'Anna salasana';

  @override
  String get please_enter_phone_or_email =>
      'Anna puhelinnumero tai sähköpostiosoite';

  @override
  String get please_provide_valid_phone_or_email =>
      'Anna kelvollinen puhelinnumero tai sähköpostiosoite';

  @override
  String get previous => 'Edellinen';

  @override
  String get privacy => 'Tietosuoja';

  @override
  String get privacy_policy => 'Tietosuojakäytäntö';

  @override
  String get profile => 'Profiili';

  @override
  String get register => 'Rekisteröidy';

  @override
  String get registration_failed => 'Rekisteröinti epäonnistui';

  @override
  String get registration_successful => 'Rekisteröinti onnistui';

  @override
  String registration_successful_message(String firstName) {
    return 'Tervetuloa Ecounityiin $firstName!';
  }

  @override
  String get references => 'Viitteet';

  @override
  String get saving_data_failed => 'Tietojen tallennus epäonnistui';

  @override
  String get quiz_not_passed => 'Et läpäissyt testiä';

  @override
  String get screenTitle_challenges => 'Haasteet';

  @override
  String get screenTitle_home => 'Koti';

  @override
  String get screenTitle_pathways => 'Polut';

  @override
  String get screenTitle_selfReflectionHub => 'Itsearviointikeskus';

  @override
  String get screenTitle_videos => 'Videot';

  @override
  String get screenTitle_lessons => 'Oppitunnit';

  @override
  String get screenTitle_modules => 'Moduulit';

  @override
  String get screenTitle_resources => 'Resurssit';

  @override
  String get select => 'Valitse';

  @override
  String get selected => 'Valittu';

  @override
  String get sendAnswer => 'Tallenna vastaus';

  @override
  String get server => 'Palvelin';

  @override
  String get settings => 'Asetukset';

  @override
  String get stage => 'Vaihe';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Ennen',
      'during': 'Aikana',
      'after': 'Jälkeen',
      'other': 'Vaihe:$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Aloita';

  @override
  String get terms => 'Käyttöehdot';

  @override
  String get unnamed => 'Nimetön';

  @override
  String get view_introduction => 'Johdanto';

  @override
  String get you_have_this_badge => 'Sinulla on tämä merkki';

  @override
  String get your_password => 'Salasanasi';

  @override
  String get view_brochure => 'Katso esite';

  @override
  String get welcome_title =>
      'Tervetuloa Ecounity-sovellukseen - porttiisi digitaaliseen oppimiseen, inspiraatioon ja yrittäjähenkiseen kasvuun.';

  @override
  String get login_introduction_text =>
      'Aloita tutustumalla SDG-oppimismoduuleihin, interaktiivisiin sarjakuviin, tietovisoihin ja luokkahuonehaasteisiin, jotka innostavat ympäristöystävälliseen toimintaan.';

  @override
  String get srh_description => 'Käytä näitä kysymyksiä pohdinnan aiheena.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'Mikä oli minulle vaikuttavinta?';

  @override
  String get srh_what_will_i_put_into_practice =>
      'Mitä aion laittaa käytäntöön?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Mitkä ovat toiveeni ja pelkoni tulevaisuutta ajatellen?';

  @override
  String get no_video_found => 'Videota ei löytynyt.';

  @override
  String get no_modules_found => 'Moduuleja ei löytynyt.';

  @override
  String get no_contents_found => 'Sisältöjä ei löytynyt.';

  @override
  String get no_resources_found => 'Resursseja ei löytynyt.';

  @override
  String get no_images_found => 'Kuvia ei löytynyt.';

  @override
  String get links => 'Linkit';

  @override
  String get refresh => 'Päivitä';

  @override
  String get cache_cleared =>
      'Välimuisti tyhjennetty. Ole hyvä ja lataa sivu uudelleen.';

  @override
  String get module_completed => 'Moduuli suoritettu';

  @override
  String get mark_as_completed => 'Merkitse suoritetuksi';

  @override
  String get mark_as_not_completed => 'Merkitse suorittamattomaksi';

  @override
  String get no_image_available => 'Kuvaa ei ole saatavilla';

  @override
  String get no_title => 'Ei otsikkoa';

  @override
  String get items_matched => 'Kohteita yhdistetty';

  @override
  String get all_items_matched => 'Kaikki kohteet yhdistetty!';

  @override
  String get play_again => 'Pelaa uudelleen';

  @override
  String get not_enough_images_to_match => 'Ei tarpeeksi yhdistettäviä kuvia';

  @override
  String get unknown => 'Ei tietoa';

  @override
  String get error_loading_button => 'Virhe painikkeen lataamisessa';

  @override
  String get seek => 'Etsi';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Huomio';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed / $total moduulia suoritettu';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed / $total oppimissisältöä suoritettu';
  }

  @override
  String get current_progress => 'Nykyinen eteneminen';

  @override
  String get next_suggestion => 'Seuraava suositus';

  @override
  String get next_up => 'Seuraavaksi:';

  @override
  String get congratulations => 'Onnittelut!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Olet suorittanut kaikki oppimissisällöt.';

  @override
  String get writeAnswerHere => 'Kirjoita vastauksesi tähän.';

  @override
  String get fieldCannotBeEmpty => 'Tätä kenttää ei voi jättää tyhjäksi.';

  @override
  String get clear_answers => 'Tyhjennä vastaukset';
}
