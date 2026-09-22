"""CineSeeker's typographic identity. No illustrated symbol or gradient."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'public/brand'; OUT.mkdir(parents=True, exist_ok=True)
def svg(body,w,h,label):
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-label="{label}">{body}</svg>\n'
def glyph(color):
 return f'<text x="10" y="72" font-family="Helvetica Neue,Arial,sans-serif" font-size="78" font-weight="700" letter-spacing="-7" fill="{color}">C/</text>'
(OUT/'mark.svg').write_text(svg(glyph('#F4F4EF'),100,100,'CineSeeker C slash'))
(OUT/'mark-mono.svg').write_text(svg(glyph('currentColor'),100,100,'CineSeeker'))
(OUT/'icon.svg').write_text(svg('<rect width="100" height="100" fill="#0A0A0A"/>'+glyph('#F4F4EF')+'<path d="M15 85H85" stroke="#FF5C29" stroke-width="3"/>',100,100,'CineSeeker'))
for name,color in [('wordmark','#F4F4EF'),('wordmark-light','#0A0A0A')]:
 body=f'<path d="M3 16V50" stroke="#FF5C29" stroke-width="5"/><text x="18" y="46" font-family="Helvetica Neue,Arial,sans-serif" font-size="32" font-weight="700" letter-spacing="-1.6" fill="{color}">CINE/SEEKER</text>'
 (OUT/f'{name}.svg').write_text(svg(body,218,66,'CineSeeker'))
body='''<rect width="1280" height="640" fill="#0A0A0A"/>
<path d="M56 126H1224 M56 544H1224 M880 158V512" stroke="#F4F4EF" stroke-opacity=".3"/>
<g fill="#F4F4EF" font-family="Courier New,Courier,monospace">
<text x="56" y="86" font-family="Helvetica Neue,Arial,sans-serif" font-size="34" font-weight="700" letter-spacing="-2">CINE/SEEKER</text>
<text x="1224" y="80" text-anchor="end" font-size="15">BAĞIMSIZ YAYIN REHBERİ / TR</text>
<text x="56" y="195" font-size="16" fill="#FF5C29">AZ GEZİN. İYİ İZLE.</text>
<text x="56" y="493" font-size="18">FİLM. DİZİ. SENİN PLATFORMLARIN.</text>
<text x="56" y="589" font-size="14">SWIFTUI / NATIVE iOS</text>
<text x="1224" y="589" text-anchor="end" font-size="14">KEŞFET / KAYDET / İZLE</text>
</g>
<g fill="#F4F4EF" font-family="Helvetica Neue,Arial,sans-serif" font-weight="900" font-size="98" letter-spacing="-5">
<text x="49" y="320">İZLEMEYE</text>
</g>
<text x="55" y="430" fill="#F4F4EF" font-family="Georgia,serif" font-style="italic" font-size="116" letter-spacing="-4">değer.</text>
<text x="901" y="395" font-family="Helvetica Neue,Arial,sans-serif" font-size="260" font-weight="700" letter-spacing="-20" fill="#F4F4EF">C/</text>
<path d="M928 455H1198" stroke="#FF5C29" stroke-width="9"/>'''
(OUT/'github-cover.svg').write_text(svg(body,1280,640,'CineSeeker. Az gezin. İyi izle. İzlemeye değer.'))
(ROOT/'app/icon.svg').write_text((OUT/'icon.svg').read_text())
for stale in [OUT/'geometry.json',ROOT/'ios/CineSeeker/Core/Theme/CineSymbol.swift']:
 if stale.exists(): stale.unlink()
