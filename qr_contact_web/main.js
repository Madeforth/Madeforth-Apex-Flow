import './style.css'
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, serverTimestamp, doc, getDoc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDxClr18Z0pme38vsrs8KWpyIwKfurZ5eE",
  authDomain: "apex-flow-7baea.firebaseapp.com",
  projectId: "apex-flow-7baea",
  storageBucket: "apex-flow-7baea.firebasestorage.app",
  messagingSenderId: "29839209813",
  appId: "1:29839209813:android:e918a9629c631cdf796bdc", // using Android appId as fallback
  measurementId: "G-RBF4QRGFWR"
};

let db = null;
try {
  const app = initializeApp(firebaseConfig);
  db = getFirestore(app);
} catch (e) {
  console.log("Firebase config not set yet.");
}

const urlParams = new URLSearchParams(window.location.search);
let vehicleId = urlParams.get('id') || urlParams.get('rider');

// If someone manually types the URL and forgets to encode '#', it might end up in the hash
if (vehicleId && window.location.hash && !vehicleId.includes('#')) {
  vehicleId = vehicleId + window.location.hash;
}

const appDiv = document.querySelector('#app');

const userLang = navigator.language || navigator.userLanguage;
const lang = userLang.startsWith('tr') ? 'tr' : userLang.startsWith('de') ? 'de' : 'en';

const i18n = {
  tr: {
    invalidQrTitle: "Geçersiz QR Kod",
    invalidQrSubtitle: "Lütfen aracın üzerindeki QR kodu tekrar okutun.",
    mainTitle: "Araç Sahibine Ulaşın",
    mainSubtitle: "Araç sahibiyle iletişime geçmek için bir sebep seçin. Kimliğiniz gizli tutulacaktır.",
    btnBlocked: "Aracınız kapıyı / yolu kapatıyor",
    btnFallen: "Aracınız Devrildi!",
    btnCrash: "Aracınıza Çarpıldı / Hasar var",
    btnTowed: "Aracınız çekiciyle çekilecektir",
    successTitle: "Bildirim Gönderildi",
    successSubtitle: "Araç sahibinin telefonuna anında bildirim iletildi. Duyarlılığınız için teşekkürler.",
    errorTitle: "İşlem Başarısız",
    errorSubtitle: "Geçersiz veya silinmiş bir QR kod okuttunuz. Sistemde böyle bir araç kaydı bulunmamaktadır.",
    spamError: "Lütfen spam yapmayınız. Yeni bir bildirim göndermek için 5 dakika beklemelisiniz.",
    ruleError: "Geçersiz veya silinmiş bir QR kod okuttunuz. Güvenlik kuralları gereği işleminiz reddedildi.",
    getItOn: "Uygulamayı İndirin",
    slogan: "Machine Relationship OS",
    driverNoteLabel: "SÜRÜCÜ NOTU:"
  },
  en: {
    invalidQrTitle: "Invalid QR Code",
    invalidQrSubtitle: "Please scan the QR code on the vehicle again.",
    mainTitle: "Contact Vehicle Owner",
    mainSubtitle: "Select a reason to contact the owner. Your identity will remain anonymous.",
    btnBlocked: "Your vehicle is blocking the door / way",
    btnFallen: "Your vehicle has fallen over!",
    btnCrash: "Your vehicle has been hit / damaged",
    btnTowed: "Your vehicle is about to be towed",
    successTitle: "Notification Sent",
    successSubtitle: "The vehicle owner has been notified instantly. Thank you for your consideration.",
    errorTitle: "Operation Failed",
    errorSubtitle: "You scanned an invalid or deleted QR code. No such vehicle exists in the system.",
    spamError: "Please do not spam. You must wait 5 minutes before sending another notification.",
    ruleError: "You scanned an invalid or deleted QR code. Your request was rejected by security rules.",
    getItOn: "Get it on",
    slogan: "Machine Relationship OS",
    driverNoteLabel: "DRIVER NOTE:"
  },
  de: {
    invalidQrTitle: "Ungültiger QR-Code",
    invalidQrSubtitle: "Bitte scannen Sie den QR-Code am Fahrzeug erneut.",
    mainTitle: "Fahrzeughalter kontaktieren",
    mainSubtitle: "Wählen Sie einen Grund. Ihre Identität bleibt anonym.",
    btnBlocked: "Ihr Fahrzeug blockiert den Weg",
    btnFallen: "Ihr Fahrzeug ist umgefallen!",
    btnCrash: "Ihr Fahrzeug wurde beschädigt",
    btnTowed: "Ihr Fahrzeug wird abgeschleppt",
    successTitle: "Benachrichtigung gesendet",
    successSubtitle: "Der Fahrzeughalter wurde sofort benachrichtigt. Vielen Dank.",
    errorTitle: "Vorgang fehlgeschlagen",
    errorSubtitle: "Sie haben einen ungültigen oder gelöschten QR-Code gescannt.",
    spamError: "Bitte warten Sie 5 Minuten, bevor Sie eine weitere Benachrichtigung senden.",
    ruleError: "Ungültiger QR-Code. Ihre Anfrage wurde vom Sicherheitssystem abgelehnt.",
    getItOn: "Jetzt bei",
    slogan: "Machine Relationship OS",
    driverNoteLabel: "FAHRER-NOTIZ:"
  }
};

const t = i18n[lang];
window.t = t; // Make available globally for sendNotification

if (!vehicleId) {
  appDiv.innerHTML = `
    <div class="card">
      <div class="logo-wrapper">
        <img src="/app_icon.png" alt="Apex Flow" class="logo-icon-large" />
        <div class="logo-text-group">
          <div class="logo-title">Apex Flow</div>
          <div class="logo-slogan">${t.slogan}</div>
        </div>
      </div>
      <div class="title">${t.invalidQrTitle}</div>
      <div class="subtitle">${t.invalidQrSubtitle}</div>
    </div>
    
    <div class="store-badge-container">
      <a href="#" target="_blank" class="store-badge">
        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9z"></path></svg>
        <div class="store-badge-text">
          <span>${t.getItOn}</span>
          <strong>Google Play</strong>
        </div>
      </a>
    </div>
    
    <div class="footer">Securely powered by Apex Flow</div>
  `;
} else {
  appDiv.innerHTML = `
    <div class="card" id="main-card">
      <div class="logo-wrapper">
        <img src="/app_icon.png" alt="Apex Flow" class="logo-icon-large" />
        <div class="logo-text-group">
          <div class="logo-title">Apex Flow</div>
          <div class="logo-slogan">${t.slogan}</div>
        </div>
      </div>
      <div class="title">${t.mainTitle}</div>
      <div class="subtitle">${t.mainSubtitle}</div>
      
      <div class="button-grid">
        <button onclick="sendNotification('Yolu Kapattı')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
          ${t.btnBlocked}
        </button>
        <button onclick="sendNotification('Devrildi')" class="urgent">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
          ${t.btnFallen}
        </button>
        <button onclick="sendNotification('Çarpıldı')" class="urgent">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
          ${t.btnCrash}
        </button>
        <button onclick="sendNotification('Çekici')" class="urgent">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
          ${t.btnTowed}
        </button>
      </div>
    </div>

    <div class="card success-message" id="success-card">
      <svg class="success-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
      <div class="title">${t.successTitle}</div>
      <div class="subtitle">${t.successSubtitle}</div>
    </div>
    
    <div class="card error-message" id="error-card" style="display: none; color: var(--accent-color);">
      <svg class="error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 48px; height: 48px; margin: 0 auto 16px; display: block;"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
      <div class="title">${t.errorTitle}</div>
      <div class="subtitle" id="error-text">${t.errorSubtitle}</div>
    </div>
    
    <div class="store-badge-container">
      <a href="#" target="_blank" class="store-badge">
        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9z"></path></svg>
        <div class="store-badge-text">
          <span>${t.getItOn}</span>
          <strong>Google Play</strong>
        </div>
      </a>
    </div>
    
    <div class="footer">Securely powered by Apex Flow</div>
  `;
}

window.sendNotification = async (reason) => {
  const mainCard = document.getElementById('main-card');
  const successCard = document.getElementById('success-card');
  const errorCard = document.getElementById('error-card');
  const errorText = document.getElementById('error-text');
  
  // Rate Limiting Check (5 minutes)
  const lastSent = localStorage.getItem(`apex_last_sent_${vehicleId}`);
  if (lastSent) {
    const timePassed = Date.now() - parseInt(lastSent);
    if (timePassed < 5 * 60 * 1000) {
      mainCard.style.display = 'none';
      errorText.innerText = window.t.spamError;
      errorCard.style.display = 'block';
      return;
    }
  }

  const buttons = document.querySelectorAll('button');
  buttons.forEach(b => b.disabled = true);
  
  if (db) {
    try {
      await addDoc(collection(db, "parking_notifications"), {
        vehicleId: vehicleId,
        reason: reason,
        timestamp: serverTimestamp(),
        read: false
      });
      // Update local storage to prevent spam
      localStorage.setItem(`apex_last_sent_${vehicleId}`, Date.now().toString());
      
      mainCard.style.display = 'none';
      successCard.style.display = 'flex';
    } catch (e) {
      console.error("Error adding document: ", e);
      mainCard.style.display = 'none';
      errorText.innerText = window.t.ruleError;
      errorCard.style.display = 'block';
    }
  } else {
    // Mock local environment
    console.log("Mock sending notification for:", reason, "to vehicle:", vehicleId);
    await new Promise(r => setTimeout(r, 800));
    mainCard.style.display = 'none';
    successCard.style.display = 'flex';
  }
};

// Fetch Driver Note if vehicleId exists
if (vehicleId && db) {
  const noteContainer = document.createElement('div');
  noteContainer.id = 'driver-note-container';
  const buttonGrid = document.querySelector('.button-grid');
  if (buttonGrid) {
    buttonGrid.parentNode.insertBefore(noteContainer, buttonGrid);
  }

  const docRef = doc(db, "rider_tags", vehicleId.toLowerCase());
  getDoc(docRef).then((docSnap) => {
    if (docSnap.exists()) {
      const data = docSnap.data();
      if (data.driverNote) {
        const noteCard = document.createElement('div');
        noteCard.className = 'driver-note-card';

        const noteLabel = document.createElement('div');
        noteLabel.className = 'driver-note-label';
        noteLabel.textContent = t.driverNoteLabel;

        const noteText = document.createElement('div');
        noteText.className = 'driver-note-text';
        noteText.textContent = `"${data.driverNote}"`;

        noteCard.appendChild(noteLabel);
        noteCard.appendChild(noteText);
        noteContainer.replaceChildren(noteCard);
      }
    }
  }).catch(e => console.log("Error fetching note:", e));
}
