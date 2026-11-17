# SENDQON PLUGIN SKELETON

Har naya Sendqon plugin yahan se shuru hota hai
(`SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md` §2.1). Copy karo,
`Example` / `example` placeholders apne plugin ke naam se badlo,
aur sirf utne stub rakho jitne us type ko chahiyein.

## Layout (live par prove shuda convention)

```
<PluginName>/
  plugin.json            manifest — slug/type/version/namespace/main_class
  src/
    <PluginName>Plugin.php   main class (contract implement karta hai)
    <PluginName>ServiceProvider.php  (runtime types ke liye)
  Runtime/               (optional) controllers, routes, services
    Routes/web.php
  migrations/            (optional) plugin ki apni tables
  README.md
```

- Directory: `app/Plugins/<TypeDirectory>/<StudlyName>/` — type
  directory `PluginManager::TYPE_DIRECTORIES` se:
  `payment_gateway → PaymentGateways`, `ai_integration →
  AiIntegrations`, `channel → Channels`, `sms_provider →
  SmsProviders`, `wa_provider → WaProviders`, `waba_provider →
  WabaProviders`, `telegram_extension → TelegramExtensions`,
  `integration → Integrations`, `tool → Tools`.
- Namespace locked: `App\Plugins\<TypeDirectory>\<StudlyName>\...`
  (manifest `namespace` = main class ka FQCN).
- Runtime types (`tool`, `ai_integration`, `integration`) ki main
  class apna runtime contract implement karti hai
  (`ToolRuntimePlugin` / `AiRuntimePlugin` /
  `IntegrationRuntimePlugin`, har ek ka `CONTRACT = 1`) aur
  manifest mein `runtime_contract: 1` lazmi hai — warna
  `PluginServiceProvider` provider register nahi karta aur
  `RuntimeCompatibility` plugin reject karta hai.
- Autoloading: `PluginManager` har plugin ke `src/` ko declared
  namespace prefix par map karta hai; `Runtime/` wale classes bhi
  usi prefix se resolve hote hain (Legacy Importer precedent).
- ZIP packaging: `scripts/package-plugin.sh <plugin-dir> <out.zip>`
  — ≤ 20 MB limit + structure validate karke ZIP banata hai.
  Install hamesha `PluginManager::installFromZip()` se (dev pehle,
  phir production), kabhi seedha file-copy se nahi (§2.2).
- Config: aam tor par plugin row ke `config` JSON mein
  (`PluginManager::configure()`); jo plugin `UsesSystemSettingConfig`
  implement kare us ka config `system_settings` mein jata hai.
  Sensitive fields schema mein `'sensitive' => true` mark karo —
  admin UI unhein mask karti hai.
- White-label: author hamesha **Sendqon**, vendor ka naam kahin
  nahi. Vendor plugin files ke watermark hisse copy NAHI karne.
