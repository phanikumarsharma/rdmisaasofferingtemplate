let armTemplateUri = 'https://raw.githubusercontent.com/noelbundick/arm-samples/master/1-storageaccount/template.json';
let deployLink = `https://portal.azure.com/#create/Microsoft.Template/uri/${encodeURIComponent(armTemplateUri)}`;
window.location = deployLink;
