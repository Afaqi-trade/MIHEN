# Family Controls dağıtım başvurusu taslağı

Hesap sahibinin Apple formunda kullanması için hazırlandı. Başvuru gönderilmedi; Apple onayı yok. Gerçek Team/Bundle ID'ler üyelik ve kayıt sonrası yazılmalıdır.

- App: MİHEN
- Primary bundle ID: `[REGISTERED_APP_BUNDLE_ID]`
- Device Activity monitor extension: `[REGISTERED_APP_BUNDLE_ID].monitor`
- Team: `[APPLE_TEAM_ID]`
- Use case: Individual authorization for personal digital wellbeing.

## English description for the application

MİHEN is a local-first personal planning and digital wellbeing iPhone app. Screen Time is optional and is enabled only after the individual user explicitly requests Family Controls authorization. The system FamilyActivityPicker lets the user choose applications, categories and web domains, then set a shared daily minute budget for that selection.

A DeviceActivityMonitor extension receives the daily usage threshold callback. ManagedSettings applies a shield to the selected tokens after the budget is reached. The user can return to MİHEN and approve a 15, 30 or 60 minute temporary opening using device-owner authentication (Face ID, Touch ID or device passcode). A separate DeviceActivity interval is scheduled before the shield is removed; expiry callbacks and foreground reconciliation restore the restriction without resetting the daily budget.

Opaque selection tokens and enforcement state remain in the app's on-device App Group. MİHEN does not read social-media content, messages or passwords and does not upload Screen Time usage or selection data to a server. The individual can revoke authorization in system Settings. Disabling the feature or deleting app data stops MİHEN's monitoring and clears its own ManagedSettings store.

We request the Family Controls distribution capability for both the main iOS app and its Device Activity Monitor extension so this optional feature can be tested through TestFlight and later distributed. The initial release is for self-management by individuals; it does not claim unrevokable parental control.

## Başvuru öncesi kontrol

Gerçek App ID'leri Apple portalına kaydedin. Açıklamanın son kaynakla uyumunu doğrulayın. Apple'ın formundaki diğer hesap/iletişim/sözleşme alanlarını hesap sahibi kendisi tamamlar; bu taslak kişisel veya hukuki bilgileri varsaymaz. TestFlight veya fiziksel cihaz doğrulamasını tamamlanmış gibi belirtmeyin.
