import os

OUT = os.path.dirname(os.path.abspath(__file__))
W, H = 390, 844  # phone frame

# ---------- shared helpers ----------

TEAL = "#0D9488"
MINT = "#2DD4BF"
BG_SOFT = "#E9F7F4"
INK = "#1E293B"
SLATE = "#64748B"
WHITE = "#FFFFFF"

def defs():
    return f'''<defs>
  <linearGradient id="teal" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="{TEAL}"/><stop offset="1" stop-color="{MINT}"/>
  </linearGradient>
  <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{WHITE}"/><stop offset="1" stop-color="{BG_SOFT}"/>
  </linearGradient>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="6" stdDeviation="10" flood-color="#0f766e" flood-opacity="0.12"/>
  </filter>
</defs>'''

def statusbar():
    return f'''<text x="30" y="30" font-family="Segoe UI" font-size="14" font-weight="600" fill="{INK}">9:41</text>
<g transform="translate(330,18)" fill="{INK}">
  <rect x="0" y="6" width="3" height="6" rx="1"/><rect x="5" y="4" width="3" height="8" rx="1"/><rect x="10" y="2" width="3" height="10" rx="1"/>
  <rect x="20" y="4" width="16" height="8" rx="2" fill="none" stroke="{INK}"/><rect x="22" y="6" width="10" height="4" rx="1"/>
</g>'''

def bg_layer(motif="waves"):
    """painted background decoration like the app"""
    s = f'<rect width="{W}" height="{H}" fill="url(#bg)"/>'
    if motif == "waves":
        s += f'<path d="M0 {H-160} Q 97 {H-200} 195 {H-160} T 390 {H-160} V{H} H0 Z" fill="{MINT}" opacity="0.15"/>'
        s += f'<path d="M0 {H-110} Q 97 {H-150} 195 {H-110} T 390 {H-110} V{H} H0 Z" fill="{TEAL}" opacity="0.18"/>'
    elif motif == "crosses":
        for cx, cy, sz, op in [(40,120,16,.10),(340,90,12,.12),(60,700,20,.08),(330,640,14,.10)]:
            s += f'<g transform="translate({cx},{cy})" opacity="{op}" fill="{TEAL}"><rect x="{-sz/4}" y="{-sz}" width="{sz/2}" height="{2*sz}" rx="3"/><rect x="{-sz}" y="{-sz/4}" width="{2*sz}" height="{sz/2}" rx="3"/></g>'
    elif motif == "ekg":
        s += f'<path d="M0 220 L80 220 L100 180 L120 260 L140 200 L160 220 L390 220" stroke="{TEAL}" stroke-width="2.5" fill="none" opacity="0.12"/>'
    elif motif == "dots":
        for i in range(6):
            for j in range(4):
                s += f'<circle cx="{300+i*16}" cy="{60+j*16}" r="2.5" fill="{TEAL}" opacity="0.15"/>'
        for i in range(6):
            for j in range(4):
                s += f'<circle cx="{20+i*16}" cy="{740+j*16}" r="2.5" fill="{TEAL}" opacity="0.12"/>'
    elif motif == "hearts":
        for hx, hy, sc, op in [(330,110,1.0,.10),(50,680,0.8,.08)]:
            s += f'<path transform="translate({hx},{hy}) scale({sc})" opacity="{op}" fill="{TEAL}" d="M0 10 C0 0 -20 0 -20 12 C-20 24 0 34 0 40 C0 34 20 24 20 12 C20 0 0 0 0 10 Z"/>'
    return s

def card(x, y, w, h, r=20, fill=WHITE):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" filter="url(#shadow)"/>'

def text(x, y, content, size=14, color=INK, weight=400, anchor="start"):
    return f'<text x="{x}" y="{y}" font-family="Segoe UI" font-size="{size}" font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{content}</text>'

def icon_badge(cx, cy, r=26, icon="heart"):
    """gradient rounded square + white glyph"""
    s = f'<rect x="{cx-r}" y="{cy-r}" width="{2*r}" height="{2*r}" rx="{r*0.6}" fill="url(#teal)"/>'
    s += glyph(cx, cy, r*0.5, icon, WHITE)
    return s

def glyph(cx, cy, s, name, color=WHITE):
    """simple vector glyphs"""
    s2 = s
    if name == "heart":
        return f'<path transform="translate({cx},{cy}) scale({s2/20})" fill="{color}" d="M0 -6 C0 -12 -14 -12 -14 -3 C-14 4 0 10 0 14 C0 10 14 4 14 -3 C14 -12 0 -12 0 -6 Z"/>'
    if name == "person":
        return f'<g transform="translate({cx},{cy}) scale({s2/12})" fill="{color}"><circle cx="0" cy="-5" r="5"/><path d="M-8 11 C-8 4 8 4 8 11 L8 12 L-8 12 Z"/></g>'
    if name == "doc":
        return f'<g transform="translate({cx-9},{cy-11}) scale(0.75)" fill="{color}"><path d="M6 0 h8 l6 6 v20 h-14 Z M14 0 v6 h6" fill-rule="evenodd"/></g>'
    if name == "pill":
        return f'<g transform="translate({cx},{cy}) rotate(-45) scale({s2/10})" fill="{color}"><rect x="-9" y="-4" width="18" height="8" rx="4"/><rect x="-1.5" y="-4" width="3" height="8" fill="{TEAL}"/></g>'
    if name == "chart":
        return f'<g transform="translate({cx},{cy}) scale({s2/12})" fill="{color}"><rect x="-9" y="0" width="5" height="10" rx="1.5"/><rect x="-2" y="-6" width="5" height="16" rx="1.5"/><rect x="5" y="3" width="5" height="7" rx="1.5"/></g>'
    if name == "chat":
        return f'<g transform="translate({cx},{cy}) scale({s2/12})" fill="{color}"><path d="M-9 -7 h18 a3 3 0 0 1 3 3 v9 a3 3 0 0 1 -3 3 h-12 l-5 4 v-4 a3 3 0 0 1 -1 -2 v-10 a3 3 0 0 1 0-3 Z"/></g>'
    if name == "cal":
        return f'<g transform="translate({cx},{cy}) scale({s2/12})" fill="none" stroke="{color}" stroke-width="2"><rect x="-9" y="-8" width="18" height="17" rx="3"/><line x1="-9" y1="-3" x2="9" y2="-3"/><line x1="-4" y1="-10" x2="-4" y2="-6"/><line x1="4" y1="-10" x2="4" y2="-6"/></g>'
    if name == "search":
        return f'<g transform="translate({cx},{cy})" fill="none" stroke="{SLATE}" stroke-width="2"><circle r="{s2}" cx="0" cy="0"/><line x1="{s2*0.7}" y1="{s2*0.7}" x2="{s2*1.5}" y2="{s2*1.5}"/></g>'
    if name == "arrow":
        return f'<g transform="translate({cx},{cy})" stroke="{color}" stroke-width="3" fill="none"><path d="M-5 -8 L5 0 L-5 8"/></g>'
    if name == "add":
        return f'<g transform="translate({cx},{cy})" stroke="{color}" stroke-width="3" fill="none"><path d="M-8 0 H8 M0 -8 V8"/></g>'
    if name == "user_md":
        return f'<g transform="translate({cx},{cy}) scale({s2/12})" fill="{color}"><circle cx="0" cy="-5" r="5"/><path d="M-8 11 C-8 4 8 4 8 11 L8 12 L-8 12 Z"/><rect x="-2" y="3" width="4" height="8" fill="{TEAL}"/><rect x="-4" y="5" width="8" height="4" fill="{TEAL}"/></g>'
    if name == "settings":
        return f'<g transform="translate({cx},{cy})" fill="none" stroke="{color}" stroke-width="2"><circle r="{s2*0.6}"/><path d="M0 -{s2} V-{s2*0.6} M0 {s2*0.6} V{s2} M-{s2} 0 H-{s2*0.6} M{s2*0.6} 0 H{s2}"/></g>'
    return ''

def field(x, y, w, label=""):
    s = f'<rect x="{x}" y="{y}" width="{w}" height="52" rx="14" fill="#F1F5F9"/>'
    if label:
        s += text(x+18, y+33, label, 13, SLATE)
    return s

def button(x, y, w, label):
    return f'<rect x="{x}" y="{y}" width="{w}" height="52" rx="26" fill="url(#teal)"/>' + text(x+w/2, y+33, label, 15, WHITE, 600, "middle")

def svg_wrap(body):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
{defs()}
{body}
</svg>'''

def save(name, body):
    with open(os.path.join(OUT, name), "w", encoding="utf-8") as f:
        f.write(svg_wrap(body))
    print("wrote", name)

# ---------- screens ----------

# 1. SPLASH
b = f'<rect width="{W}" height="{H}" fill="url(#teal)"/>'
b += f'<circle cx="60" cy="80" r="90" fill="{WHITE}" opacity="0.06"/><circle cx="350" cy="720" r="120" fill="{WHITE}" opacity="0.06"/>'
b += f'<rect x="135" y="300" width="120" height="120" rx="36" fill="{WHITE}" filter="url(#shadow)"/>'
b += glyph(195, 360, 46, "heart", TEAL)
b += text(195, 480, "Lyra", 40, WHITE, 700, "middle")
b += text(195, 512, "Fertility care, connected", 15, "#D6F5F0", 400, "middle")
b += f'<rect x="155" y="600" width="80" height="4" rx="2" fill="{WHITE}" opacity="0.35"/><rect x="155" y="600" width="34" height="4" rx="2" fill="{WHITE}"/>'
save("01_Splash_Screen.svg", b)

# 2. ROLE SELECT
b = bg_layer("hearts") + statusbar()
b += f'<rect x="24" y="60" width="342" height="130" rx="24" fill="url(#teal)" filter="url(#shadow)"/>'
b += text(48, 118, "Welcome to Lyra", 22, WHITE, 700)
b += text(48, 144, "We help you to be complete", 13, "#D6F5F0")
for i, (label, icon) in enumerate([("Doctor", "user_md"), ("Patient", "person")]):
    y = 230 + i*130
    b += card(24, y, 342, 105)
    b += icon_badge(70, y+52, 26, icon)
    b += text(112, y+47, label, 17, INK, 600)
    b += text(112, y+70, "Sign in to continue" if i==0 else "View your care", 12, SLATE)
    b += f'<rect x="316" y="{y+36}" width="34" height="34" rx="17" fill="url(#teal)"/>' + glyph(333, y+53, 8, "arrow", WHITE)
b += text(195, 560, "Select your role to continue", 12, SLATE, 400, "middle")
save("02_Role_Select.svg", b)

# 3. DOCTOR LOGIN
b = bg_layer("waves") + statusbar()
b += icon_badge(195, 150, 40, "user_md")
b += text(195, 230, "Doctor Login", 24, INK, 700, "middle")
b += text(195, 256, "Sign in to manage patients", 13, SLATE, 400, "middle")
b += card(24, 290, 342, 290, 24)
b += field(44, 320, 302, "User ID")
b += field(44, 388, 302, "Password")
b += button(44, 460, 302, "LOGIN")
b += text(195, 545, "Forgot Password?", 13, TEAL, 600, "middle")
save("03_Doctor_Login.svg", b)

# 4. DOCTOR DASHBOARD
b = bg_layer("ekg") + statusbar()
b += text(24, 60, "Lyra", 20, TEAL, 700)
b += f'<circle cx="352" cy="54" r="18" fill="{BG_SOFT}"/>' + glyph(352, 54, 10, "person", TEAL)
b += f'<rect x="24" y="88" width="342" height="110" rx="22" fill="url(#teal)" filter="url(#shadow)"/>'
b += text(48, 132, "Patient Care", 19, WHITE, 700)
b += text(48, 156, "Track every patient’s journey", 12, "#D6F5F0")
b += glyph(330, 143, 22, "heart", WHITE)
tiles = [("Patients","person"),("Add Patient","add"),("My Profile","doc"),("Logout","arrow")]
for i,(label,icon) in enumerate(tiles):
    y = 232 + i*88
    b += card(24, y, 342, 72)
    b += f'<rect x="40" y="{y+16}" width="40" height="40" rx="12" fill="{BG_SOFT}"/>' + glyph(60, y+36, 11, icon, TEAL)
    b += text(96, y+42, label, 15, INK, 600)
    b += glyph(344, y+36, 8, "arrow", SLATE)
save("04_Doctor_Dashboard.svg", b)

# 5. PATIENT LIST
b = bg_layer("dots") + statusbar()
b += text(24, 60, "Patients", 20, INK, 700)
b += field(24, 80, 342) + text(44, 113, "Search patients", 13, SLATE) + glyph(346, 106, 8, "search")
names = [("Gayathri","ID 361"),("Geetha","ID 205"),("Shivani","ID 365"),("Prathiba","ID 374")]
for i,(nm,uid) in enumerate(names):
    y = 152 + i*84
    b += card(24, y, 342, 68)
    b += f'<circle cx="58" cy="{y+34}" r="22" fill="{BG_SOFT}"/>' + glyph(58, y+34, 12, "person", TEAL)
    b += text(92, y+30, nm, 15, INK, 600)
    b += text(92, y+50, uid, 12, SLATE)
    b += glyph(344, y+34, 8, "arrow", SLATE)
save("05_Patient_List.svg", b)

# 6. PATIENT DETAIL HUB
b = bg_layer("crosses") + statusbar()
b += f'<circle cx="195" cy="120" r="42" fill="url(#teal)"/>' + glyph(195, 120, 24, "person", WHITE)
b += text(195, 185, "Gayathri", 20, INK, 700, "middle")
b += text(195, 206, "Patient ID: 361", 12, SLATE, 400, "middle")
b += card(24, 232, 342, 150, 20)
b += text(44, 262, "Basic Details", 15, TEAL, 700)
for i,(k,v) in enumerate([("Age","28  ·  Female"),("Blood Group","O+ve"),("Contact","+91 98XXX XXX21")]):
    b += text(44, 292+i*30, k, 12, SLATE)
    b += text(200, 292+i*30, v, 12, INK, 600)
b += card(24, 398, 342, 130, 20)
b += text(44, 428, "Medical History", 15, TEAL, 700)
b += text(44, 456, "LMP: 02 Oct 2026  ·  Flow: Regular", 12, SLATE)
b += text(44, 480, "Obstetric: G0 P0  ·  Surgical: Nil", 12, SLATE)
b += text(44, 504, "Consanguineous: No", 12, SLATE)
b += card(24, 544, 342, 100, 20)
b += text(44, 574, "Quick Actions", 15, TEAL, 700)
for i,(label,icon) in enumerate([("Reports","doc"),("Medicines","pill"),("Advice","chat"),("Graph","chart"),("Cycle","cal")]):
    x = 60 + i*68
    b += f'<rect x="{x-22}" y="592" width="44" height="44" rx="14" fill="{BG_SOFT}"/>' + glyph(x, 614, 11, icon, TEAL)
save("06_Patient_Detail.svg", b)

# 7. PATIENT DASHBOARD (cycle ring hero)
b = bg_layer("hearts") + statusbar()
b += text(24, 60, "Lyra", 20, TEAL, 700)
b += f'<circle cx="352" cy="54" r="18" fill="{BG_SOFT}"/>' + glyph(352, 54, 10, "person", TEAL)
b += card(24, 88, 342, 240, 24)
b += text(195, 122, "Cycle Tracker", 15, SLATE, 600, "middle")
b += f'<circle cx="195" cy="212" r="72" fill="none" stroke="{BG_SOFT}" stroke-width="14"/>'
b += f'<circle cx="195" cy="212" r="72" fill="none" stroke="url(#teal)" stroke-width="14" stroke-linecap="round" stroke-dasharray="330 452" transform="rotate(-90 195 212)"/>'
b += text(195, 208, "DAY", 13, SLATE, 600, "middle")
b += text(195, 238, "12", 34, TEAL, 700, "middle")
b += f'<rect x="130" y="296" width="130" height="30" rx="15" fill="{BG_SOFT}"/>'
b += text(195, 316, "Fertile: Oct 14–19", 11, TEAL, 600, "middle")
grid = [("Reports","doc"),("Advice","chat"),("Graphs","chart"),("Medicines","pill")]
for i,(label,icon) in enumerate(grid):
    x = 24 + (i%2)*175
    y = 356 + (i//2)*130
    b += card(x, y, 167, 110, 20)
    b += icon_badge(x+40, y+46, 22, icon)
    b += text(x+83.5, y+88, label, 14, INK, 600, "middle")
b += card(24, 640, 342, 70, 18)
b += glyph(60, 675, 12, "chat", TEAL)
b += text(92, 671, "Need help?", 14, INK, 600)
b += text(92, 692, "Chat with the clinic on WhatsApp", 11, SLATE)
save("07_Patient_Dashboard.svg", b)

# 8. ADD PATIENT FORM
b = bg_layer("crosses") + statusbar()
b += text(24, 60, "Add Patient", 20, INK, 700)
b += f'<circle cx="195" cy="128" r="34" fill="{BG_SOFT}" stroke="{TEAL}" stroke-width="2" stroke-dasharray="5 4"/>' + glyph(195, 128, 16, "add", TEAL)
b += text(195, 182, "Patient Photo", 11, SLATE, 400, "middle")
b += card(24, 206, 342, 200, 20)
b += text(44, 236, "Basic Details", 15, TEAL, 700)
b += field(44, 254, 140, "Name") + field(198, 254, 140, "Age")
b += field(44, 318, 140, "Contact No") + field(198, 318, 140, "Blood Group  ▾")
b += card(24, 422, 342, 180, 20)
b += text(44, 452, "Medical History", 15, TEAL, 700)
b += field(44, 470, 140, "LMP  📅") + field(198, 470, 140, "Flow  ▾")
b += f'<rect x="44" y="534" width="90" height="30" rx="15" fill="url(#teal)"/>' + text(89, 554, "Yes", 12, WHITE, 600, "middle")
b += f'<rect x="140" y="534" width="90" height="30" rx="15" fill="{BG_SOFT}"/>' + text(185, 554, "No", 12, SLATE, 600, "middle")
b += text(44, 528, "Consanguineous", 11, SLATE)
b += button(24, 640, 342, "CONTINUE  →")
save("08_Add_Patient.svg", b)

# 9. REPORT ENTRY
b = bg_layer("ekg") + statusbar()
b += text(24, 60, "Add Report", 20, INK, 700)
b += f'<rect x="24" y="80" width="342" height="54" rx="16" fill="url(#teal)"/>'
b += glyph(58, 107, 12, "cal", WHITE) + text(84, 112, "14 Oct 2026", 15, WHITE, 600)
b += card(24, 152, 342, 150, 20)
b += text(44, 182, "Scan Report", 15, TEAL, 700)
b += field(44, 196, 140, "Endometrium (mm)") + field(198, 196, 140, "Follicle (mm)")
b += field(44, 260, 140, "RI") + field(198, 260, 140, "PSV")
b += card(24, 318, 342, 210, 20)
b += text(44, 348, "Blood Investigations", 15, TEAL, 700)
b += field(44, 362, 140, "FSH") + field(198, 362, 140, "LH")
b += field(44, 426, 140, "TSH") + field(198, 426, 140, "Prolactin")
b += field(44, 490, 140, "AMH")
b += f'<rect x="24" y="556" width="342" height="90" rx="20" fill="{BG_SOFT}" stroke="{TEAL}" stroke-width="1.5" stroke-dasharray="6 5"/>'
b += glyph(195, 590, 14, "add", TEAL)
b += text(195, 624, "Tap to upload scan image", 12, SLATE, 400, "middle")
b += button(24, 680, 342, "SAVE REPORT")
save("09_Add_Report.svg", b)

print("\nAll SVG designs generated in:", OUT)
