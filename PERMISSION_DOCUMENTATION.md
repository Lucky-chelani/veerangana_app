# 🔒 Veerangana App - Permission Usage Documentation

## Play Store Permission Declaration

This document explains why each permission is required for the Veerangana Women Safety App and how they are used to ensure user safety.

## 📱 Required Permissions & Justifications

### 🌐 Network & Internet
| Permission | Justification |
|------------|---------------|
| `INTERNET` | **Required for:** Firebase authentication, cloud storage, AI chatbot communication, emergency service APIs, and real-time data synchronization |
| `ACCESS_NETWORK_STATE` | **Required for:** Checking internet connectivity before sending emergency alerts to ensure reliability |

### 📍 Location Services (Critical for Safety)
| Permission | Justification |
|------------|---------------|
| `ACCESS_FINE_LOCATION` | **Required for:** Precise GPS coordinates for emergency services, nearby hospital/police station detection, and accurate location sharing during emergencies |
| `ACCESS_COARSE_LOCATION` | **Required for:** General area detection when fine location is unavailable, ensuring emergency services can still locate the user |
| `ACCESS_BACKGROUND_LOCATION` | **Required for:** Continuous safety monitoring, automatic emergency detection, and location tracking during distress situations even when app is not actively used |

### 📞 Communication (Emergency Features)
| Permission | Justification |
|------------|---------------|
| `CALL_PHONE` | **Required for:** Direct emergency calling to police (100), ambulance (108), fire (101), and user's emergency contacts with one-tap functionality |
| `READ_PHONE_STATE` | **Required for:** Detecting ongoing calls to prevent interference with emergency calls and managing call states during emergencies |
| `SEND_SMS` | **Required for:** Automatic emergency SMS with location coordinates to emergency contacts and authorities when voice calls are not possible |

### 👥 Contacts (Emergency Network)
| Permission | Justification |
|------------|---------------|
| `READ_CONTACTS` | **Required for:** Selecting and managing emergency contacts from phone book, enabling quick setup of safety network without manual entry |

### 📸 Media & Recording (Evidence Collection)
| Permission | Justification |
|------------|---------------|
| `CAMERA` | **Required for:** Recording photo/video evidence during unsafe situations, documenting incidents for legal purposes, and capturing visual proof for authorities |
| `RECORD_AUDIO` | **Required for:** Audio recording during emergencies for evidence, voice messages to emergency contacts, and sound-based threat detection |

### 💾 Storage (Data Security)
| Permission | Justification |
|------------|---------------|
| `READ_EXTERNAL_STORAGE` | **Required for:** Accessing stored emergency data, retrieving saved evidence files, and reading security-related documents |
| `WRITE_EXTERNAL_STORAGE` | **Required for:** Saving emergency recordings, storing evidence securely, and backing up critical safety data (Android 10 and below) |
| `READ_MEDIA_IMAGES` | **Required for:** Accessing image evidence and safety-related photos (Android 13+) |
| `READ_MEDIA_VIDEO` | **Required for:** Accessing video evidence and safety recordings (Android 13+) |
| `READ_MEDIA_AUDIO` | **Required for:** Accessing audio evidence and voice recordings (Android 13+) |

### ⚡ System Services (Reliability)
| Permission | Justification |
|------------|---------------|
| `FOREGROUND_SERVICE` | **Required for:** Continuous safety monitoring, background location tracking, and ensuring emergency features work even when app is minimized |
| `FOREGROUND_SERVICE_LOCATION` | **Required for:** Background location services for automatic emergency detection and continuous safety monitoring |
| `WAKE_LOCK` | **Required for:** Keeping device active during emergency situations, preventing screen timeout during critical operations, and maintaining connectivity |
| `RECEIVE_BOOT_COMPLETED` | **Required for:** Automatically restarting safety services after device reboot to ensure continuous protection |

### 📳 Device Features (Alert System)
| Permission | Justification |
|------------|---------------|
| `VIBRATE` | **Required for:** Silent emergency alerts, discreet notifications during unsafe situations, and accessibility features for hearing-impaired users |
| `ACTIVITY_RECOGNITION` | **Required for:** Detecting sudden movements, fall detection, shake-to-activate emergency features, and automatic threat recognition |

## 🛡️ Privacy & Security Measures

### Data Protection
- All sensitive data encrypted locally and in transit
- Location data used only for emergency purposes
- Recordings stored securely with user consent
- Emergency contacts protected with encryption

### User Control
- Granular permission requests with clear explanations
- Option to revoke permissions while maintaining core safety features
- Transparent data usage with detailed privacy policy
- User can delete all data at any time

### Minimal Data Collection
- Only collect data essential for safety features
- No tracking for advertising purposes
- No sharing with third parties except emergency services
- Automatic data cleanup after configurable periods

## 🚨 Emergency Use Cases

### Scenario 1: Physical Threat
1. **Shake Detection** → `ACTIVITY_RECOGNITION`
2. **Location Sharing** → `ACCESS_FINE_LOCATION`
3. **Emergency Call** → `CALL_PHONE`
4. **SMS Alert** → `SEND_SMS`
5. **Evidence Recording** → `CAMERA`, `RECORD_AUDIO`

### Scenario 2: Medical Emergency
1. **One-tap Emergency** → `CALL_PHONE`
2. **Location to Ambulance** → `ACCESS_FINE_LOCATION`
3. **Contact Family** → `READ_CONTACTS`, `SEND_SMS`
4. **Background Monitoring** → `FOREGROUND_SERVICE`

### Scenario 3: Stalking/Harassment
1. **Discreet Recording** → `CAMERA`, `RECORD_AUDIO`
2. **Silent Alerts** → `VIBRATE`
3. **Evidence Storage** → `WRITE_EXTERNAL_STORAGE`
4. **Background Tracking** → `ACCESS_BACKGROUND_LOCATION`

## 📊 Play Store Data Safety Declaration

### Data Types Collected:
- **Location:** For emergency services and safety features
- **Personal Info:** Emergency contacts only
- **Audio/Video:** Evidence recordings with explicit consent
- **App Activity:** Usage analytics for safety feature improvement

### Data Sharing:
- **Emergency Services:** Location and contact info during emergencies only
- **No Third Parties:** No data sharing for commercial purposes
- **User Control:** Complete control over data sharing preferences

### Data Security:
- **Encryption:** All data encrypted in transit and at rest
- **Secure Storage:** Local device storage with system-level protection
- **Access Control:** Biometric/PIN protection for sensitive features

## 🎯 Compliance Standards

### Android Guidelines
- ✅ Permissions requested only when needed
- ✅ Clear explanation for each permission
- ✅ Runtime permission requests with context
- ✅ Graceful handling of denied permissions

### Play Store Policies
- ✅ Sensitive permissions justified with safety use cases
- ✅ No excessive permissions beyond app functionality
- ✅ Transparent privacy policy covering all data usage
- ✅ User consent for all data collection

### Legal Compliance
- ✅ GDPR compliance for EU users
- ✅ Data protection laws adherence
- ✅ User rights to data deletion and portability
- ✅ Clear terms of service and privacy policy

---

**Note:** All permissions are essential for the core safety functionality of the Veerangana Women Safety App. The app cannot provide effective emergency protection without these permissions, as they enable critical features like location sharing, emergency calling, evidence recording, and automatic threat detection.
