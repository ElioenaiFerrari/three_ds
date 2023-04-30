// Transaction

/**
 * @typedef {object} Transaction
 * @property {string} server_id
 * @property {string} [acs_id]
 * @property {string} [acs_url]
 * @property {Encrypted} [authentication_value]
 * @property {"done" | "refused" | "not_performed"} [challenge_indicator]
 * @property {string} [device_channel]
 * @property {"done" | "refused" | "not_performed"} [fingerprint_indicator]
 * @property {string} [fingerprint_url]
 * @property {string} [stone_id]
 * @property {string} protocol_version
 * @property {Date} inserted_at
 * @property {Date} updated_at
 */

// PreAuth

/**
 * @typedef {object} PreAuthRequest
 * @property {string} account_number
 */

/**
 * @typedef {object} PreAuthResponse
 * @property {string} server_id
 * @property {string} fingerprint_url
 * @property {string} protocol_version
 */

// Auth

/**
 * @typedef {object} Address
 * @property {string} street
 * @property {string} number
 * @property {string} county
 * @property {string} city
 * @property {string} state
 * @property {"BRA"} country
 * @property {string} zip_code
 */

/**
 * @typedef {object} Browser
 * @property {number} color_depth
 * @property {boolean} java_enabled
 * @property {boolean} javascript_enabled
 * @property {string} language
 * @property {number} screen_height
 * @property {number} screen_width
 * @property {number} tz
 * @property {string} accept_header
 * @property {string} ip
 * @property {string} user_agent
 */

/**
 * @typedef {object} Phone
 * @property {"55"} country_code
 * @property {"30049680"} subscriber
 * @property {"personal" | "work"} phone_type
 */

/**
 * @typedef {object} PaymentCard
 * @property {number} expiry_date
 * @property {"credit" | "debit"} type
 * @property {Date} holder
 * @property {"visa" | "master" | "maestro" | "elo" | "american_express" | "diners_club" | "hiper" | "hiper_card" | "discover" | "jcb"} brand
 */

/**
 * @typedef {object} Purchase
 * @property {number} amount
 * @property {"BRL"} currency
 * @property {Date} date
 * @property {number} installments
 */

/**
 * @typedef {object} AuthRequest
 * @property {string} account_number
 * @property {"not_applicable"| "credit" | "debit"} account_type
 * @property {string} address_match
 * @property {string} email
 * @property {Address} billing_address
 * @property {Browser} browser
 * @property {PaymentCard} payment_card
 * @property {"app" | "browser" | "three_ds_requestor"} device_channel
 * @property {"done" | "refused" | "not_performed"} challenge_cycle_indicator
 * @property {string} requestor_url
 * @property {Phone[]} phones
 * @property {Purchase} purchase
 * @property {Address} shipping_address
 * @property {string} transaction_server_id
 * @property {"purchase_service" | "check_acceptance" | "account_funding" | "quasi_cash" | "prepaid_activation"} transaction_type
 */

//  PostMessageEvent
/**
 * @typedef {object} PostMessageEvent
 * @property {"fingerprint_done" | "challenge_done"} event_type
 * @property {Transaction} data
 * @property {object} error
 */

let fingerprintTimeout, challengeTimeout;

const apiBaseUrl = 'http://localhost:4000/api';
const submit = document.querySelector('button#three-ds-form__submit');

const base64url = (str) => {
  let bs = btoa(str);
  bs = bs.replace(/\+/g, '-');
  bs = bs.replace(/\//g, '_');
  bs = bs.replace(/=+$/, '');
  return bs;
};

const simpleKeyValueString = (message) => {
  return objectToKeyValueString({ message });
};

addEventListener('load', async (e) => {
  e.preventDefault();
});

/**
 * @param {"Pre auth" | "Fingerprint" | "Auth" | "Post auth" | "Start" | "Done"} step
 * @param {"ok" | "error" | "warning"} level
 * @param {string} message
 */
const insertInTimeline = (step, level, message) => {
  const timelineEl = document.querySelector('ul#three-ds-timeline');
  if (step === 'Start') {
    timelineEl.classList.remove('hidden');

    while (timelineEl.firstChild) {
      timelineEl.removeChild(timelineEl.firstChild);
    }
  }

  const item = document.createElement('li');
  item.classList.add(`three-ds-timeline__item-${level}`);

  const container = document.createElement('div');
  container.classList.add(`three-ds-timeline__item-${level}__container`);
  const title = document.createElement('h3');
  title.classList.add(`three-ds-timeline__item-${level}__container__title`);
  title.innerText = `${step} ${level}`;
  const description = document.createElement('p');
  description.classList.add(
    `three-ds-timeline__item-${level}__container__description`
  );
  description.innerHTML = message;

  container.appendChild(title);
  container.appendChild(description);
  item.appendChild(container);
  timelineEl.appendChild(item);
};

/**
 *
 * @param {object} payload
 * @param {string} separator
 */
const objectToKeyValueString = (payload, separator = '<br/>') => {
  const items = [];
  for (const key in payload) {
    items.push(`<b>${key}</b>: ${payload[key]}`);
  }

  return items.join(separator);
};

/**
 * @param {PreAuthRequest} payload
 * @returns {PreAuthResponse}
 */
const preAuth = async (payload) => {
  const json = JSON.stringify(payload);
  const response = await fetch(`${apiBaseUrl}/pre_auth`, {
    method: 'POST',
    body: json,
    headers: { 'Content-Type': 'application/json' },
  });

  const preAuthResponse = await response.json();
  insertInTimeline('Pre auth', 'ok', objectToKeyValueString(preAuthResponse));

  return preAuthResponse;
};

/**
 * @param {PreAuthResponse} preAuthResponse
 * @returns {Transaction}
 */
const fingerprint = async (preAuthResponse) => {
  addEventListener('message', onFingerprintDone);
  fingerprintTimeout = setTimeout(() => {
    insertInTimeline(
      'Fingerprint',
      'error',
      simpleKeyValueString('timeout exceeded')
    );
    removeEventListener('message', onFingerprintDone);
    clearTimeout(fingerprintTimeout);
  }, 10_000);

  const fingerprintEl = document.querySelector('div#three-ds-fingerprint');

  const fingerprintIframeEl = document.createElement('iframe');
  fingerprintIframeEl.name = 'three-ds-fingerprint__iframe';
  fingerprintIframeEl.style.display = 'none';

  fingerprintEl.appendChild(fingerprintIframeEl);

  // Generate the data object with required input values
  const payload = {
    threeDSServerTransID: preAuthResponse.server_id,
    threeDSMethodNotificationURL: 'http://localhost:4000/api/fingerprint',
  };

  // Get a reference to the form
  const form = document.querySelector('form#three-ds-fingerprint__form');

  // 1. Serialize threeDSMethodData object into JSON
  // 2. Base64-URL encode it
  // 3. Store the value in the form input tag
  // Notice: You have to define base64url() yourself.
  // Warning: The Base64-URL value must not be padded with '='
  const fingerprintPayloadEl = document.querySelector(
    'input#threeDSMethodData'
  );
  fingerprintPayloadEl.value = base64url(JSON.stringify(payload));

  form.action = preAuthResponse.fingerprint_url;
  form.target = 'three-ds-fingerprint__iframe'; // id of iframe
  form.method = 'post';
  form.submit();
};

/**
 * @param {{data: PostMessageEvent}} event
 */
const onFingerprintDone = async (event) => {
  const { event_type: eventType, data: transaction, error } = event.data;

  if (eventType === 'fingerprint_done') {
    clearTimeout(fingerprintTimeout);
    insertInTimeline('Fingerprint', 'ok', objectToKeyValueString(transaction));

    const accountNumber = document.querySelector(
      'input#three-ds-form__account-number'
    );
    const authResponse = await auth({
      transaction_server_id: transaction.server_id,
      account_number: accountNumber.value,
      account_type: 'debit',
      address_match: 'Y',
      billing_address: {
        city: 'Vila Velha',
        country: 'BRA',
        county: 'Centro',
        number: '785',
        state: 'ES',
        street: 'Rodovia do Sol',
        zip_code: '29102020',
      },
      browser: {
        accept_header: '*',
        color_depth: screen.colorDepth,
        ip: '127.0.0.1',
        java_enabled: navigator.javaEnabled(),
        javascript_enabled: true,
        language: navigator.language,
        screen_height: screen.height,
        screen_width: screen.width,
        tz: new Date().getTimezoneOffset(),
        user_agent: navigator.userAgent,
      },
      challenge_cycle_indicator: 'done',
      device_channel: 'browser',
      email: 'test@test.com',
      payment_card: {
        brand: 'visa',
        expiry_date: '10/28',
        holder: 'Eli',
        type: 'credit',
      },
      phones: [
        {
          country_code: '55',
          type: 'personal',
          subscriber: '30049680',
        },
      ],
      purchase: {
        amount: 20000,
        currency: 'BRL',
        date: new Date(),
        installments: 2,
      },
      requestor_url: 'https://elioenai-ferrari.vercel.app/',
      shipping_address: {
        street: 'Rua do Passeio',
        number: '38',
        county: 'Centro',
        city: 'Rio de Janeiro',
        state: 'RJ',
        country: 'BRA',
        zip_code: '20021290',
      },
      transaction_type: 'purchase_service',
    });
    await challenge(authResponse);
  }
};

/**
 * @param {AuthRequest} payload
 * @returns {Transaction}
 */
const auth = async (payload) => {
  const json = JSON.stringify(payload);

  const response = await fetch(`${apiBaseUrl}/auth`, {
    method: 'POST',
    body: json,
    headers: { 'Content-Type': 'application/json' },
  });

  const transaction = await response.json();

  insertInTimeline('Auth', 'ok', objectToKeyValueString(transaction));

  return transaction;
};

/**
 * @param {Transaction} transaction
 */
const challenge = async (transaction) => {
  addEventListener('message', onChallengeDone);
  challengeTimeout = setTimeout(() => {
    insertInTimeline(
      'Post auth',
      'error',
      simpleKeyValueString('timeout exceeded')
    );
    removeEventListener('message', onChallengeDone);
  }, 10_000);

  const challengeEl = document.querySelector('div#three-ds-challenge');

  const challengeIframeEl = document.createElement('iframe');
  challengeIframeEl.name = 'three-ds-challenge__iframe';

  challengeEl.appendChild(challengeIframeEl);

  // Generate the data object
  const payload = {
    threeDSServerTransID: transaction.server_id,
    acsTransID: transaction.acs_id,
    messageVersion: transaction.protocol_version,
    messageType: 'CReq',
    challengeWindowSize: '01',
  };

  // Get a reference to the form
  const form = document.querySelector('form#three-ds-challenge__form');

  const challengePayloadEl = document.querySelector('input#creq');
  challengePayloadEl.value = base64url(JSON.stringify(payload));

  // Fill out the form information and submit.
  form.action = transaction.acs_url; // The acsURL from the ARes.
  form.target = 'three-ds-challenge__iframe';
  form.method = 'post';
  form.submit();

  challengeEl.classList.remove('hidden');
};

/**
 * @param {{data: PostMessageEvent}} event
 */
const onChallengeDone = async (event) => {
  const { event_type: eventType, data: transaction, error } = event.data;

  if (eventType === 'challenge_done') {
    clearTimeout(challengeTimeout);
    insertInTimeline('Post auth', 'ok', objectToKeyValueString(transaction));
    const challengeEl = document.querySelector('div#three-ds-challenge');
    const submit = document.querySelector('button#three-ds-form__submit');

    let challengeIframe = challengeEl.querySelector(
      "iframe[name='three-ds-challenge__iframe']"
    );

    while (challengeIframe) {
      challengeIframe.remove();
      challengeIframe = challengeEl.querySelector(
        "iframe[name='three-ds-challenge__iframe']"
      );
    }

    challengeEl.classList.add('hidden');
    submit.classList.remove('disabled');

    insertInTimeline('Done', 'ok', '');
  }
};

submit.addEventListener('click', async (e) => {
  e.preventDefault();
  if (submit.classList.contains('disabled')) return;

  insertInTimeline('Start', 'ok', '');

  submit.classList.add('disabled');
  const accountNumber = document.querySelector(
    'input#three-ds-form__account-number'
  );

  const preAuthResponse = await preAuth({
    account_number: accountNumber.value,
  });

  await fingerprint(preAuthResponse);
});
