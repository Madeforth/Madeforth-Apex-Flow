enum BugCategory {
  speedTelemetry,
  gpsDrift,
  uiLayout,
  garageMaintenance,
  crashFreeze,
  connectivity,
  other;

  String get labelTr {
    switch (this) {
      case BugCategory.speedTelemetry:
        return 'Hız Hesaplama / Kalman';
      case BugCategory.gpsDrift:
        return 'GPS Kayması / Konum';
      case BugCategory.uiLayout:
        return 'Arayüz / Tasarım';
      case BugCategory.garageMaintenance:
        return 'Garaj / Bakım';
      case BugCategory.crashFreeze:
        return 'Çökme / Donma';
      case BugCategory.connectivity:
        return 'Bağlantı / İnternet';
      case BugCategory.other:
        return 'Diğer';
    }
  }

  String get labelEn {
    switch (this) {
      case BugCategory.speedTelemetry:
        return 'Speed Math / Kalman';
      case BugCategory.gpsDrift:
        return 'GPS Drift / Location';
      case BugCategory.uiLayout:
        return 'UI / Layout';
      case BugCategory.garageMaintenance:
        return 'Garage / Maintenance';
      case BugCategory.crashFreeze:
        return 'Crash / Freeze';
      case BugCategory.connectivity:
        return 'Connectivity / Network';
      case BugCategory.other:
        return 'Other';
    }
  }

  String get labelDe {
    switch (this) {
      case BugCategory.speedTelemetry:
        return 'Geschwindigkeit / Kalman';
      case BugCategory.gpsDrift:
        return 'GPS-Drift / Standort';
      case BugCategory.uiLayout:
        return 'Benutzeroberfläche / Layout';
      case BugCategory.garageMaintenance:
        return 'Garage / Wartung';
      case BugCategory.crashFreeze:
        return 'Absturz / Einfrieren';
      case BugCategory.connectivity:
        return 'Konnektivität / Netzwerk';
      case BugCategory.other:
        return 'Sonstiges';
    }
  }

  String get tag {
    switch (this) {
      case BugCategory.speedTelemetry:
        return 'SPEED_TELEMETRY';
      case BugCategory.gpsDrift:
        return 'GPS_DRIFT';
      case BugCategory.uiLayout:
        return 'UI_LAYOUT';
      case BugCategory.garageMaintenance:
        return 'GARAGE';
      case BugCategory.crashFreeze:
        return 'CRASH';
      case BugCategory.connectivity:
        return 'CONNECTIVITY';
      case BugCategory.other:
        return 'GENERAL';
    }
  }
}

enum BugPriority {
  p0, // Emergency / Test blocking
  p1, // High impact
  p2, // Medium / Feature bug
  p3; // Low / Cosmetic

  String get label {
    switch (this) {
      case BugPriority.p0:
        return 'P0 - Kritik (Kilitleyen)';
      case BugPriority.p1:
        return 'P1 - Yüksek';
      case BugPriority.p2:
        return 'P2 - Orta';
      case BugPriority.p3:
        return 'P3 - Düşük';
    }
  }
}

enum BugStatus {
  submitted,
  newReport,
  needsInfo,
  confirmed,
  inProgress,
  readyForRetest,
  fixed,
  closed,
  duplicate;

  String get code {
    switch (this) {
      case BugStatus.submitted:
        return 'submitted';
      case BugStatus.newReport:
        return 'new';
      case BugStatus.needsInfo:
        return 'needs_info';
      case BugStatus.confirmed:
        return 'confirmed';
      case BugStatus.inProgress:
        return 'in_progress';
      case BugStatus.readyForRetest:
        return 'ready_for_retest';
      case BugStatus.fixed:
        return 'fixed';
      case BugStatus.closed:
        return 'closed';
      case BugStatus.duplicate:
        return 'duplicate';
    }
  }

  static BugStatus fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'submitted':
        return BugStatus.submitted;
      case 'new':
        return BugStatus.newReport;
      case 'needs_info':
        return BugStatus.needsInfo;
      case 'confirmed':
        return BugStatus.confirmed;
      case 'in_progress':
        return BugStatus.inProgress;
      case 'ready_for_retest':
        return BugStatus.readyForRetest;
      case 'fixed':
        return BugStatus.fixed;
      case 'closed':
        return BugStatus.closed;
      case 'duplicate':
        return BugStatus.duplicate;
      default:
        return BugStatus.submitted;
    }
  }

  String getLabel(String langCode) {
    if (langCode == 'tr') {
      switch (this) {
        case BugStatus.submitted:
          return 'Rapor Alındı';
        case BugStatus.newReport:
          return 'İnceleniyor';
        case BugStatus.needsInfo:
          return 'Ek Bilgi Bekleniyor';
        case BugStatus.confirmed:
          return 'Doğrulandı';
        case BugStatus.inProgress:
          return 'Çalışılıyor';
        case BugStatus.readyForRetest:
          return 'Yeniden Test Et';
        case BugStatus.fixed:
          return 'Düzeltildi';
        case BugStatus.closed:
          return 'Kapatıldı';
        case BugStatus.duplicate:
          return 'Mükerrer Kayıt';
      }
    }
    if (langCode == 'de') {
      switch (this) {
        case BugStatus.submitted:
          return 'Eingereicht';
        case BugStatus.newReport:
          return 'In Prüfung';
        case BugStatus.needsInfo:
          return 'Info erforderlich';
        case BugStatus.confirmed:
          return 'Bestätigt';
        case BugStatus.inProgress:
          return 'In Bearbeitung';
        case BugStatus.readyForRetest:
          return 'Bereit zum Testen';
        case BugStatus.fixed:
          return 'Behoben';
        case BugStatus.closed:
          return 'Geschlossen';
        case BugStatus.duplicate:
          return 'Duplikat';
      }
    }
    switch (this) {
      case BugStatus.submitted:
        return 'Submitted';
      case BugStatus.newReport:
        return 'In Triage';
      case BugStatus.needsInfo:
        return 'Needs Info';
      case BugStatus.confirmed:
        return 'Confirmed';
      case BugStatus.inProgress:
        return 'In Progress';
      case BugStatus.readyForRetest:
        return 'Ready for Retest';
      case BugStatus.fixed:
        return 'Fixed';
      case BugStatus.closed:
        return 'Closed';
      case BugStatus.duplicate:
        return 'Duplicate';
    }
  }
}
