/** SIGE IP v8.5 — Conector somente leitura de todas as abas, inclusive ocultas. */
function doGet(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const includeHidden = String((e && e.parameter && e.parameter.hidden) || 'true') !== 'false';
    const requested = e && e.parameter && e.parameter.sheet;
    const sheets = ss.getSheets()
      .filter(sh => (includeHidden || !sh.isSheetHidden()) && (!requested || sh.getName() === requested))
      .map(sh => {
        const range = sh.getDataRange();
        return {name:sh.getName(),gid:sh.getSheetId(),hidden:sh.isSheetHidden(),rows:range.getDisplayValues(),rowCount:range.getNumRows(),columnCount:range.getNumColumns()};
      });
    return ContentService.createTextOutput(JSON.stringify({version:'8.5',spreadsheetId:ss.getId(),spreadsheetName:ss.getName(),generatedAt:new Date().toISOString(),sheetCount:sheets.length,sheets:sheets})).setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({error:String(err && err.stack || err)})).setMimeType(ContentService.MimeType.JSON);
  }
}
