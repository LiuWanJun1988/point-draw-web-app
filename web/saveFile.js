"use strict";

async function saveFile(data) {
    const pickerGeneralOpts = {
      types: [
        {
          description: 'Images',
          accept: {
            'image/*': ['.png', '.gif', '.jpeg', '.jpg', '.bmp']
          }
        },
      ],
      excludeAcceptAllOption: true,
      multiple: false,
    };

    const fsfh = await window.showSaveFilePicker(pickerGeneralOpts);

    const writable = await fsfh.createWritable();

    await writable.write(data);

    await writable.close();
}

async function saveSVGFile(data) {
    const pickerSVGOpts = {
      types: [
        {
          description: 'Scalable vector graphic images',
          accept: {
            'image/svg+xml': ['.svg']
          }
        },
      ],
      excludeAcceptAllOption: false,
      multiple: false,
    };

    const fsfh = await window.showSaveFilePicker(pickerSVGOpts);

    const writable = await fsfh.createWritable();

    await writable.write(data);

    await writable.close();
}