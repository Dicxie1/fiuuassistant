const { initializeApp } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { defineSecret } = require('firebase-functions/params');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const twilio = require('twilio');

initializeApp();

const db = getFirestore();
const twilioAccountSid = defineSecret('TWILIO_ACCOUNT_SID');
const twilioAuthToken = defineSecret('TWILIO_AUTH_TOKEN');
const twilioFromNumber = defineSecret('TWILIO_FROM_NUMBER');
const SEND_COOLDOWN_MS = 60 * 1000;

function toE164(phone) {
  const digits = phone.trim().replace(/[\s()-]/g, '');
  if (/^\d{8}$/.test(digits)) return `+505${digits}`;
  if (/^505\d{8}$/.test(digits)) return `+${digits}`;
  if (/^\+[1-9]\d{7,14}$/.test(digits)) return digits;
  return null;
}

exports.sendEmergencyLocation = onCall(
  {
    region: 'us-central1',
    secrets: [twilioAccountSid, twilioAuthToken, twilioFromNumber],
    maxInstances: 2,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Debes iniciar sesión.');
    }

    const { latitude, longitude } = request.data || {};
    if (
      typeof latitude !== 'number' ||
      typeof longitude !== 'number' ||
      !Number.isFinite(latitude) ||
      !Number.isFinite(longitude) ||
      latitude < -90 || latitude > 90 ||
      longitude < -180 || longitude > 180
    ) {
      throw new HttpsError('invalid-argument', 'La ubicación no es válida.');
    }

    const uid = request.auth.uid;
    const contactRef = db.collection('emergency_contacts').doc(uid);
    const cooldownRef = db.collection('emergency_sms_rate_limits').doc(uid);
    const contactSnapshot = await contactRef.get();
    if (!contactSnapshot.exists) {
      throw new HttpsError(
        'failed-precondition',
        'No hay un contacto de emergencia configurado.'
      );
    }

    const contact = contactSnapshot.data();
    const destination = toE164(String(contact.phone || ''));
    if (!destination) {
      throw new HttpsError(
        'failed-precondition',
        'El teléfono del contacto debe tener formato internacional o ser un número local de Nicaragua de 8 dígitos.'
      );
    }

    const now = Date.now();
    await db.runTransaction(async (transaction) => {
      const previous = await transaction.get(cooldownRef);
      const previousTime = previous.get('sentAt');
      if (
        previousTime instanceof Timestamp &&
        now - previousTime.toMillis() < SEND_COOLDOWN_MS
      ) {
        throw new HttpsError(
          'resource-exhausted',
          'Ya se envió una alerta recientemente.'
        );
      }
      transaction.set(cooldownRef, { sentAt: Timestamp.fromMillis(now) });
    });

    const mapsUrl = `https://maps.google.com/?q=${latitude},${longitude}`;
    const message = [
      '🚨 EMERGENCIA ACTIVADA 🚨',
      `${contact.name || 'Contacto'}, necesito ayuda.`,
      `Ubicación actual: ${mapsUrl}`,
    ].join('\n');

    try {
      const client = twilio(twilioAccountSid.value(), twilioAuthToken.value());
      const sent = await client.messages.create({
        body: message,
        from: twilioFromNumber.value(),
        to: destination,
      });
      return { sent: true, messageSid: sent.sid };
    } catch (error) {
      await cooldownRef.delete();
      console.error('Twilio emergency SMS failed:', error);
      throw new HttpsError('unavailable', 'No se pudo enviar el SMS.');
    }
  }
);
