# Elif-Ba Ses Eğitimi (MVP)

Flutter tabanlı “Elif-Ba Ses Eğitimi” uygulamasının minimum çalışır sürümü. Amaç, Android’de mikrofondan ses kaydı alıp dosya yolunu ekranda göstermek.

## Özellikler
- Material 3 arayüzü.
- Hedef hece seçimi (ثَ / ثِ / ثُ).
- Mikrofon izni kontrolü ve isteği (permission_handler).
- Ses kaydı başlatma/durdurma ve dönen path’in ekranda gösterilmesi (record).

## Proje yapısı
```
lib/
  app/           # Tema ve uygulama ayarları
  features/recorder/  # Kayıt ekranı, durum modeli, servis
  shared/widgets/     # Ortak UI bileşenleri
```

## Kurulum ve çalıştırma
1. Flutter SDK yolunu `android/local.properties` içinde `flutter.sdk` satırına kendi ortamınıza göre yazın.
2. Bağımlılıkları indirmek için kök dizinde:
   ```bash
   flutter pub get
   ```
3. Android’de çalıştırmak için:
   ```bash
   flutter run
   ```

## GitHub'a gönderim (push)
1. Mevcut değişiklikleri kontrol edin:
   ```bash
   git status -sb
   ```
2. Gerekirse commit oluşturun (örnek):
   ```bash
   git add .
   git commit -m "Mesajınız"
   ```
3. Uzak depoya gönderin:
   ```bash
   git push origin work
   ```

### Push hatası için ipucu
GitHub "ikili dosyalar desteklenmez" benzeri bir uyarı verirse, genellikle yanlışlıkla `build/` veya `node_modules/` gibi büyük/derlenmiş klasörler eklenmiştir. Sorunu çözmek için:
- `git status` ile takip edilen dosyaları kontrol edin; gerekirse `git restore --staged <dosya>` ile temizleyin.
- Tekrar commit ve push deneyin.
- Bu repo, ikili boyut uyarılarından kaçınmak için `android/gradle/wrapper/gradle-wrapper.jar` dosyasını versiyon kontrolüne eklemez. Flutter projesi önce Gradle wrapper dosyasını isteme hatası verirse, aşağıdaki komutu çalıştırarak jar’ı yerelde yeniden üretebilirsiniz:
  ```bash
  ./gradlew wrapper
  ```
  Bu işlem jar’ı yeniden oluşturur ancak `.gitignore` sayesinde depoya eklenmez.

## Android izni
`android/app/src/main/AndroidManifest.xml` dosyasına `android.permission.RECORD_AUDIO` izni eklendi. Manifest içinde, `<application>` etiketinden önce tanımlıdır.

## iOS notu
`ios/Runner/Info.plist` içine `NSMicrophoneUsageDescription` anahtarını eklemeniz gerekir. Bu MVP’de iOS için kurulum tamamlanmadı; ileride eklenmelidir.

## Notlar
- Ağ, yapay zekâ veya backend entegrasyonu yoktur.
- Kod, küçük ve okunabilir parçalara ayrılmıştır; gerektiğinde açıklayıcı yorumlar eklenmiştir.
