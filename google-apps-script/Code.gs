/** SIGE IP v8.4 — Conector somente leitura de TODAS as abas. */
function doGet(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const includeHidden = String((e && e.parameter && e.parameter.hidden) || 'false') === 'true';
    const requested = e && e.parameter && e.parameter.sheet;
    const sheets = ss.getSheets()
      .filter(sh => (includeHidden || !sh.isSheetHidden()) && (!requested || sh.getName() === requested))
      .map(sh => {
        const range = sh.getDataRange();
        return { name: sh.getName(), gid: sh.getSheetId(), rows: range.getDisplayValues(), rowCount: range.getNumRows(), columnCount: range.getNumColumns() };
      });
    return ContentService.createTextOutput(JSON.stringify({spreadsheetId:ss.getId(),spreadsheetName:ss.getName(),generatedAt:new Date().toISOString(),sheetCount:sheets.length,sheets:sheets})).setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({error:String(err && err.stack || err)})).setMimeType(ContentService.MimeType.JSON);
  }
}
