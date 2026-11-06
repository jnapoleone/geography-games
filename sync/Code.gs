/**
 * @OnlyCurrentDoc
 *
 * Geography Games progress receiver. Paste this into the Sheet's Apps Script editor.
 *
 * It can only ADD result rows to this Sheet. There is no doGet and nothing here returns
 * Sheet contents, so the public site can't read anything back.
 * Every field must match a strict pattern, so nobody can inject a formula or free text.
 */
const COLUMNS = ['received_at', 'at', 'device', 'app', 'kind', 'item', 'result', 'value', 'event_id'];
const ID_COLUMN = 9;
const MAX_BODY = 65536;      // bytes per request
const MAX_BATCH = 200;       // rows per request
const MAX_PER_MINUTE = 120;  // requests per minute, all devices together
const MAX_ROWS = 200000;     // stops junk data from filling the Sheet
const DEDUPE_WINDOW = 20000; // recent rows checked for repeats

const WORD = /^[A-Za-z0-9][A-Za-z0-9_.:-]{0,63}$/;
const LONG_WORD = /^[A-Za-z0-9][A-Za-z0-9_.:-]{0,119}$/;
const DEVICE = /^[0-9a-f]{12}$/;
const WHEN = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z$/;

function reply(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}

function optional(v) {
  const s = v === undefined || v === null ? '' : String(v);
  return s === '' || WORD.test(s) ? s : null;
}

function toRow(device, e, now) {
  if (!e || typeof e !== 'object') return null;
  const at = String(e.at);
  const id = String(e.id);
  const app = String(e.app);
  const kind = String(e.kind);
  const item = optional(e.item);
  const result = optional(e.result);
  const value = optional(e.value);
  if (!WHEN.test(at) || !LONG_WORD.test(id) || !WORD.test(app) || !WORD.test(kind)) return null;
  if (item === null || result === null || value === null) return null;
  return [now, at, device, app, kind, item, result, value, id];
}

function underRateLimit() {
  const cache = CacheService.getScriptCache();
  const key = 'rate-' + Math.floor(Date.now() / 60000);
  const count = Number(cache.get(key) || 0);
  if (count >= MAX_PER_MINUTE) return false;
  cache.put(key, String(count + 1), 120);
  return true;
}

function doPost(request) {
  const lock = LockService.getScriptLock();
  let locked = false;
  try {
    const body = request && request.postData && request.postData.contents;
    if (!body || body.length > MAX_BODY) return reply({ ok: false });
    if (!underRateLimit()) return reply({ ok: false });

    const data = JSON.parse(body);
    if (!data || !DEVICE.test(String(data.d)) || !Array.isArray(data.e) || data.e.length > MAX_BATCH) {
      return reply({ ok: false });
    }

    lock.waitLock(20000);
    locked = true;

    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
    if (sheet.getLastRow() === 0) {
      sheet.appendRow(COLUMNS);
      sheet.setFrozenRows(1);
    }
    const last = sheet.getLastRow();
    if (last >= MAX_ROWS) return reply({ ok: false });

    const seen = {};
    const count = Math.min(last - 1, DEDUPE_WINDOW);
    if (count > 0) {
      sheet.getRange(last - count + 1, ID_COLUMN, count, 1).getValues().forEach(function (r) { seen[r[0]] = true; });
    }

    const now = new Date().toISOString();
    const rows = [];
    let repeats = 0;
    let rejected = 0;
    data.e.forEach(function (e) {
      const row = toRow(String(data.d), e, now);
      if (!row) { rejected++; return; }
      if (seen[row[8]]) { repeats++; return; }
      seen[row[8]] = true;
      rows.push(row);
    });

    if (rows.length) {
      const range = sheet.getRange(last + 1, 1, rows.length, COLUMNS.length);
      range.setNumberFormat('@'); // keep every value as plain text
      range.setValues(rows);
    }
    return reply({ ok: true, added: rows.length, repeats: repeats, rejected: rejected });
  } catch (err) {
    return reply({ ok: false });
  } finally {
    if (locked) lock.releaseLock();
  }
}
