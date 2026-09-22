import fs from 'node:fs';
import sharp from 'sharp';
async function render() {
  await sharp('public/brand/github-cover.svg').png().toFile('public/brand/github-cover.png');
  await sharp('public/brand/app-icon.png').resize(180, 180).png().toFile('app/apple-icon.png');
  const png = await sharp('public/brand/icon.svg').resize(64, 64).png().toBuffer();
  const header = Buffer.alloc(22);
  header.writeUInt16LE(1, 2); header.writeUInt16LE(1, 4);
  header[6] = 64; header[7] = 64;
  header.writeUInt16LE(1, 10); header.writeUInt16LE(32, 12);
  header.writeUInt32LE(png.length, 14); header.writeUInt32LE(22, 18);
  fs.writeFileSync('app/favicon.ico', Buffer.concat([header, png]));
}
render().catch(error => { console.error(error); process.exitCode = 1; });
