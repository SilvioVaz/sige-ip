/**
 * SIGE IP — conector somente leitura para Google Sheets.
 * Vincule este projeto à planilha e publique como Aplicativo da Web.
 */
function doGet(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const requested = e && e.parameter && e.parameter.sheet;
    const sheets = ss.getSheets()
      .filter(sh => !requested || sh.getName() === requested)
      .map(sh => ({
        name: sh.getName(),
        gid: sh.getSheetId(),
        rows: sh.getDataRange().getDisplayValues()
      }));
    return ContentService
      .createTextOutput(JSON.stringify({
        spreadsheetId: ss.getId(),
        spreadsheetName: ss.getName(),
        generatedAt: new Date().toISOString(),
        sheets: sheets
      }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({error: String(err)}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
