# 🏴‍☠️ GANG SISTEM ZA ESX LEGACY

## 📦 INSTALACIJA

1. **Kreiraj folder** u `resources/`: `gangs`
2. **Unesi sve fajlove** (client.lua, server.lua, fxmanifest.lua, gangs.sql)
3. **Kreiraj bazu podataka** - Unesi `gangs.sql` u tvoju MySQL bazu
4. **Dodaj u server.cfg**: `ensure gangs`
5. **Restartaj server**

---

## 🛣️ GANGS U SISTEMU

- **GSF** - Crvena boja (255, 0, 0) 🔴
- **Ballas** - Plava boja (0, 0, 255) 🔵
- **Bloods** - Tamno crvena (139, 0, 0) 🔴
- **Vagos** - Žuta boja (255, 255, 0) 🟡
- **Marabunta** - Zelena boja (0, 255, 0) 🟢

---

## 🚗 VOZILA PO MARKI

Svaka banda može spawnati sljedeća vozila:

- 🏎️ **Declasse Sabre Turbo** (sabrturbo) x2
- 🚗 **Vapid Dominator** (dominator) x2
- 🚙 **Albany Buccaneer** (buccaneur) x2
- 🏎️ **Imponte Phoenix** (phoenix) x2
- 🚘 **Declasse Tornado** (tornado) x2

**Ukupno: 10 vozila po bandi (1-10)**

---

## 📋 KOMANDE

### Za igrače:

```
/car [1-10]          - Spawnaj vozilo
```

Primjer: `/car 1` - Spawnaj prvo vozilo (Sabre Turbo)

---

### Za admina:

```
/addgang [ID] [GANG] - Dodaj igrača u bangu
/removegang [ID]     - Uklonji igrača iz bande
```

Primjer:
```
/addgang 1 GSF       - Dodaj igrača ID 1 u GSF
/removegang 1        - Uklonji igrača ID 1 iz bande
```

---

## 💰 PLJAČKA BANKE

### Kako funkcionira:

1. **Dostavi se do banke** sa blip-om na mapi (Kosturska glava 💀)
2. **Pritisnite [E]** ako ste član bande
3. **Trebaju najmanje 5 članova** bande na mapi
4. **Maksimalno 10 članova** za pljačku
5. **Čekaj 5 minuta** - Timer će se prikazati
6. **Dobij 500,000$** nakon završetka

### Pljačka zahtjevi:
- ✅ Minimum članova: **5**
- ✅ Maksimum članova: **10**
- ✅ Nagrada: **$500,000**
- ✅ Trajanje: **5 minuta**

---

## 🗺️ MINI MAPA

- **Blip ikona**: Kosturska glava (277) 💀
- **Vidljiva samo**: Za članove bande
- **Boje**: Prema boji bande
- **Lokacije**: Razne lokacije na mapi

---

## 🔧 KONFIGURACIJA

Sve lokacije i postavke možeš promijeniti u:
- **client.lua** - Lokacije banki, boje, vozila
- **server.lua** - Nagrade, vremensko trajanje

Primjer promjene nagrade:
```lua
Config.RobberySettings = {
    minMembers = 5,
    maxMembers = 10,
    reward = 500000,  -- Promijeni ovdje
    duration = 300000
}
```

---

## 🐛 TROUBLESHOOTING

**Nije vidljivo vozilo?**
- Provjeri je li model u `Config.Gangs[].vehicles`

**Pljačka ne radi?**
- Provjeri je li dovoljno članova bande online
- Provjeri SQL bazu

**Nema blipa?**
- Provjeri je li igrač član bande
- Restartaj resurs

---

## 📝 SQL BAZA

Tabele:
- `gang_members` - Članovi bandi
- `gang_data` - Podatci o bandama
- `gang_vehicles` - Spawnana vozila

---

**Napravljeno za ESX Legacy 🎮**