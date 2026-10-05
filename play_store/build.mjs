import { writeFileSync, mkdirSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';

const ROOT = resolve(import.meta.dirname);
const SRC = resolve(ROOT, 'screenshots/src');
const OUT = resolve(ROOT, 'screenshots/out');
const HTML = resolve(ROOT, 'html');
mkdirSync(OUT, { recursive: true });
mkdirSync(HTML, { recursive: true });

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

const slides = [
  {
    img: 'product.png',
    pw: 470,
    kicker: 'Premium Engineering',
    h1: ['Cylinder testing,', 'digital & compliant'],
    sub: 'One app for test entry, calculations, approvals and the certificate that follows.',
    chips: [],
    footer: ['IS 7285 Part 2', 'PESO licence workflow', 'Role-based approvals'],
  },
  {
    img: 'vehicle.png',
    kicker: 'Step 1 · Booking',
    h1: ['Dealer, vehicle', 'and dues together'],
    sub: 'Mobile number, test amount and next due date line up as you type.',
    chips: [
      ['Dealer auto-fill', 'Mobile pulls itself'],
      ['Live billing', 'Amount + pending dues'],
      ['Next due date', 'Auto, three years on'],
      ['Cascade number', 'Validated before entry'],
    ],
  },
  {
    img: 'primary.png',
    kicker: 'Step 2 · Measure',
    h1: ['Test readings,', 'zero manual math'],
    sub: 'Tare weight, diameter and water capacity drive the whole calculation sheet.',
    chips: [
      ['Minimum thickness', 'Calculated for you'],
      ['Shell + bottom', 'Two reading slots'],
      ['Pressure fields', 'Working & test preset'],
      ['Inspection grid', 'Valve, visual, internal'],
    ],
  },
  {
    img: 'result.png',
    kicker: 'Step 3 · Verdict',
    h1: ['Pass or fail,', 'before you submit'],
    sub: 'Expansion and wall thickness are checked the moment you type the reading.',
    chips: [
      ['Permanent expansion', 'Initial vs total'],
      ['Expansion %', 'Against the IS limit'],
      ['Auto result', 'PASS / FAIL on screen'],
      ['Reject path', 'Separate cylinder log'],
    ],
  },
  {
    img: 'photos.png',
    kicker: 'Evidence',
    h1: ['Photo proof', 'at the spot'],
    sub: 'Number plate and cylinder marking attach to the certificate itself.',
    chips: [
      ['Camera or gallery', 'One tap capture'],
      ['Auto compress', 'Uploads fast on site'],
      ['Preview & retake', 'Before you submit'],
      ['Tied to cert no', 'Audit ready'],
    ],
  },
  {
    img: 'makes.png',
    kicker: 'Master data',
    h1: ['Every make,', 'one search away'],
    sub: 'Approved cylinder makers and gas types stay in step with the licence.',
    chips: [
      ['125 makes', 'Search by name or code'],
      ['Gas wise lists', 'CNG · LPG · O2 · N2'],
      ['No typos', 'Pick from the list'],
      ['Updated centrally', 'Same for every user'],
    ],
  },
  {
    img: 'licence.png',
    kicker: 'Compliance',
    h1: ['Licence on track,', 'paperwork done'],
    sub: 'Approval number, status and expiry are visible before the first test starts.',
    chips: [
      ['PESO licence', 'Approval + expiry view'],
      ['Active / expired', 'Flagged on screen'],
      ['Two roles', 'Capture · Approve'],
      ['Print & PDF', 'Signed calculation sheet'],
    ],
  },
];

const css = `
@font-face{font-family:P;font-weight:300;src:url(file://${ROOT}/fonts/Poppins-Light.ttf)}
@font-face{font-family:P;font-weight:500;src:url(file://${ROOT}/fonts/Poppins-Medium.ttf)}
@font-face{font-family:P;font-weight:600;src:url(file://${ROOT}/fonts/Poppins-SemiBold.ttf)}
@font-face{font-family:P;font-weight:700;src:url(file://${ROOT}/fonts/Poppins-Bold.ttf)}
@font-face{font-family:P;font-weight:800;src:url(file://${ROOT}/fonts/Poppins-ExtraBold.ttf)}
@font-face{font-family:P;font-weight:900;src:url(file://${ROOT}/fonts/Poppins-Black.ttf)}
*{margin:0;padding:0;box-sizing:border-box}
body{width:1080px;height:1920px;overflow:hidden;font-family:P;position:relative;
  background:
    radial-gradient(900px 700px at 88% 4%, rgba(0,206,222,.20), transparent 62%),
    radial-gradient(1000px 800px at 4% 96%, rgba(96,120,225,.42), transparent 60%),
    linear-gradient(163deg,#080E38 0%,#141E62 42%,#22308F 78%,#2C3A8C 100%);
}
.ring{position:absolute;border-radius:50%;border:1.5px solid rgba(255,255,255,.07)}
.r1{width:1500px;height:1500px;top:-720px;right:-560px}
.r2{width:1100px;height:1100px;top:-520px;right:-380px;border-color:rgba(0,206,222,.10)}
.r3{width:1300px;height:1300px;bottom:-780px;left:-520px}
.dot{position:absolute;border-radius:50%;background:#00CEDE}
.beam{position:absolute;width:1500px;height:520px;left:-260px;top:1180px;transform:rotate(-18deg);
  background:linear-gradient(90deg,transparent,rgba(0,206,222,.10),transparent);filter:blur(28px)}
.wrap{position:relative;height:100%;padding:74px 56px 0;display:flex;flex-direction:column;align-items:center}
.brand{width:100%;display:flex;align-items:center;gap:20px}
.brand svg{width:62px;height:62px;flex:none}
.brand .bn{font-weight:900;font-size:29px;letter-spacing:5.5px;color:#fff;line-height:1.12}
.brand .bn em{display:block;font-style:normal;font-weight:600;font-size:19px;letter-spacing:6px;color:#00CEDE}
.head{width:100%;margin-top:52px;text-align:center}
.kicker{display:inline-block;font-weight:700;font-size:26px;letter-spacing:5px;text-transform:uppercase;color:#8FE9F5;
  background:rgba(0,206,222,.13);border:1px solid rgba(0,206,222,.35);padding:13px 30px;border-radius:999px}
h1{margin-top:30px;font-weight:800;font-size:82px;line-height:1.04;letter-spacing:-1.5px;color:#fff}
h1 .l2{display:block;background:linear-gradient(96deg,#3FE0EE 6%,#8FF3FF 52%,#3FA9F5 96%);
  -webkit-background-clip:text;background-clip:text;-webkit-text-fill-color:transparent}
.sub{margin:26px auto 0;max-width:880px;font-weight:500;font-size:33px;line-height:1.42;color:rgba(255,255,255,.70)}
.stage{position:relative;width:100%;flex:1;margin-top:30px;display:flex;justify-content:center;align-items:center}
.rig{position:relative;display:flex;justify-content:center}
.phone{position:relative;z-index:2;width:460px;flex:none;border-radius:68px;padding:15px;
  background:linear-gradient(158deg,#6E7FD8 0%,#212C6E 34%,#0A1038 74%,#3A47A0 100%);
  box-shadow:0 46px 96px rgba(0,0,0,.62), 0 0 0 1px rgba(255,255,255,.10) inset, 0 0 130px rgba(0,190,222,.22)}
.screen{border-radius:53px;overflow:hidden;background:#0B1024;position:relative}
.screen img{display:block;width:100%}
.screen.c img{height:100%;object-fit:cover;object-position:top center}
.glare{position:absolute;inset:0;border-radius:53px;pointer-events:none;
  background:linear-gradient(126deg,rgba(255,255,255,.14) 0%,rgba(255,255,255,0) 34%,rgba(255,255,255,0) 68%,rgba(255,255,255,.06) 100%)}
.chip{position:absolute;width:240px;z-index:3;padding:22px 20px 20px;border-radius:26px;
  background:rgba(255,255,255,.085);border:1px solid rgba(255,255,255,.17);
  box-shadow:0 22px 46px rgba(4,8,32,.42);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px)}
.chip .ic{width:48px;height:48px;border-radius:15px;display:flex;align-items:center;justify-content:center;
  background:linear-gradient(140deg,#00CEDE,#1D6FE0);box-shadow:0 10px 22px rgba(0,180,215,.42);margin-bottom:13px}
.chip .ic svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:2.6;stroke-linecap:round;stroke-linejoin:round}
.chip b{display:block;font-weight:700;font-size:25px;line-height:1.16;color:#fff;letter-spacing:-.4px}
.chip span{display:block;margin-top:6px;font-weight:500;font-size:20px;line-height:1.26;color:rgba(255,255,255,.62)}
.L{left:-252px}.R{right:-252px}
.L::after{content:'';position:absolute;top:52px;right:-12px;width:12px;height:2px;
  background:linear-gradient(90deg,rgba(0,206,222,.75),rgba(0,206,222,0))}
.R::after{content:'';position:absolute;top:52px;left:-12px;width:12px;height:2px;
  background:linear-gradient(270deg,rgba(0,206,222,.75),rgba(0,206,222,0))}
.foot{width:100%;padding:0 0 46px;display:flex;flex-direction:column;align-items:center;gap:26px}
.dots{display:flex;gap:12px}
.dots i{width:12px;height:12px;border-radius:999px;background:rgba(255,255,255,.24)}
.dots i.on{width:44px;background:linear-gradient(90deg,#00CEDE,#8FF3FF)}
.tagrow{font-weight:600;font-size:24px;letter-spacing:3.4px;color:rgba(255,255,255,.42);text-transform:uppercase}
.pills{display:flex;gap:16px;flex-wrap:wrap;justify-content:center}
.pill{font-weight:600;font-size:25px;letter-spacing:.4px;color:#DFF7FC;padding:15px 28px;border-radius:999px;
  background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.16)}
.pill b{color:#00CEDE;font-weight:800;margin-right:9px}
.tag{position:absolute;right:-14px;top:-26px;font-weight:800;font-size:26px;letter-spacing:1px;color:#062130;
  background:linear-gradient(120deg,#5CF0D6,#00CEDE);padding:14px 26px;border-radius:999px;
  box-shadow:0 16px 34px rgba(0,206,222,.42)}
`;

const check =
  '<svg viewBox="0 0 24 24"><path d="M20 6 9 17l-5-5"/></svg>';
const logo = `<svg viewBox="0 0 100 100"><g fill="#1DA7D8"><path d="M50 8c9 12 14 19 14 26a14 14 0 1 1-28 0c0-7 5-14 14-26z" transform="translate(0,4)"/><path d="M50 8c9 12 14 19 14 26a14 14 0 1 1-28 0c0-7 5-14 14-26z" transform="rotate(120 50 52)"/><path d="M50 8c9 12 14 19 14 26a14 14 0 1 1-28 0c0-7 5-14 14-26z" transform="rotate(240 50 52)" fill="#101A4D"/></g></svg>`;

const dots = (n) =>
  Array.from({ length: n })
    .map((_, i) => {
      const x = [7, 92, 4, 95, 12, 88, 48, 70, 26][i % 9];
      const y = [12, 22, 47, 62, 78, 88, 6, 40, 30][i % 9];
      const s = [10, 7, 13, 8, 11, 6, 9, 12, 7][i % 9];
      const o = [0.5, 0.32, 0.42, 0.25, 0.55, 0.3, 0.4, 0.22, 0.48][i % 9];
      return `<i class="dot" style="left:${x}%;top:${y}%;width:${s}px;height:${s}px;opacity:${o}"></i>`;
    })
    .join('');

function slideHtml(s, idx) {
  const chips = s.chips
    .map((c, i) => {
      const side = i % 2 === 0 ? 'L' : 'R';
      const row = Math.floor(i / 2);
      const y = side === 'L' ? 90 + row * 430 : 300 + row * 430;
      return `<div class="chip ${side}" style="top:${y}px"><div class="ic">${check}</div><b>${c[0]}</b><span>${c[1]}</span></div>`;
    })
    .join('');

  const pills = (s.footer || [])
    .map((f) => `<div class="pill"><b>&#10003;</b>${f}</div>`)
    .join('');

  const dotsRow = slides
    .map((_, i) => `<i class="${i === idx ? 'on' : ''}"></i>`)
    .join('');

  return `<!doctype html><html><head><meta charset="utf-8"><style>${css}</style></head><body>
<div class="ring r1"></div><div class="ring r2"></div><div class="ring r3"></div><div class="beam"></div>${dots(9)}
<div class="wrap">
  <div class="brand">${logo}<div class="bn">PREMIUM<em>ENGINEERING</em></div></div>
  <div class="head">
    <div class="kicker">${s.kicker}</div>
    <h1>${s.h1[0]}<span class="l2">${s.h1[1]}</span></h1>
    <p class="sub">${s.sub}</p>
  </div>
  <div class="stage"><div class="rig">
    ${chips}
    <div class="phone" style="width:${s.pw || 460}px"><div class="screen${s.sh ? ' c' : ''}"${s.sh ? ` style="height:${s.sh}px"` : ''}><img src="file://${SRC}/${s.img}"><div class="glare"></div></div></div>
  </div></div>
  <div class="foot">${pills ? `<div class="pills">${pills}</div>` : ''}<div class="dots">${dotsRow}</div></div>
</div></body></html>`;
}

slides.forEach((s, i) => {
  const file = resolve(HTML, `slide${i + 1}.html`);
  writeFileSync(file, slideHtml(s, i));
  const png = resolve(OUT, `premium-engineering-${i + 1}.png`);
  execFileSync(CHROME, [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--force-device-scale-factor=1',
    '--default-background-color=00000000',
    `--screenshot=${png}`,
    '--window-size=1080,1920',
    '--virtual-time-budget=4000',
    `file://${file}`,
  ]);
  console.log('rendered', png);
});
