import SwiftUI

// MARK: - Lawful Audio License Information
public enum LicenseType: String, Codable, CaseIterable {
    case publicDomain = "publicDomain"
    case creativeCommonsZero = "cc0"
    case creativeCommonsBy = "ccBy"
    case creativeCommonsBySa = "ccBySa"
    case creativeCommonsByNc = "ccByNc"
    case jamendoPersonal = "jamendoPersonal"
    case freeMusicArchive = "freeMusicArchive"
    case directAuthorized = "directAuthorized"
    case streamOnly = "streamOnly"
    
    public var displayName: String {
        switch self {
        case .publicDomain: return "Public Domain"
        case .creativeCommonsZero: return "CC0 1.0 Public Domain"
        case .creativeCommonsBy: return "CC BY 4.0 (Attribution)"
        case .creativeCommonsBySa: return "CC BY-SA 4.0 (ShareAlike)"
        case .creativeCommonsByNc: return "CC BY-NC 4.0 (Non-Commercial)"
        case .jamendoPersonal: return "Jamendo Lawful License"
        case .freeMusicArchive: return "Free Music Archive Distribution"
        case .directAuthorized: return "Direct Authorized Audio"
        case .streamOnly: return "Stream / Preview Only"
        }
    }
    
    public var shortBadge: String {
        switch self {
        case .publicDomain: return "CC0"
        case .creativeCommonsZero: return "CC0"
        case .creativeCommonsBy: return "CC BY"
        case .creativeCommonsBySa: return "CC BY-SA"
        case .creativeCommonsByNc: return "CC BY-NC"
        case .jamendoPersonal: return "Jamendo"
        case .freeMusicArchive: return "FMA"
        case .directAuthorized: return "Authorized"
        case .streamOnly: return "Preview Only"
        }
    }
    
    public var isDownloadAllowed: Bool {
        switch self {
        case .streamOnly:
            return false
        default:
            return true
        }
    }
    
    public var requiresAttribution: Bool {
        switch self {
        case .creativeCommonsBy, .creativeCommonsBySa, .creativeCommonsByNc, .jamendoPersonal, .freeMusicArchive:
            return true
        default:
            return false
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .publicDomain, .creativeCommonsZero, .creativeCommonsBy, .creativeCommonsBySa, .directAuthorized:
            return Theme.success
        case .creativeCommonsByNc, .jamendoPersonal, .freeMusicArchive:
            return Theme.purple
        case .streamOnly:
            return Theme.warning
        }
    }
    
    public var badgeIcon: String {
        switch self {
        case .publicDomain, .creativeCommonsZero:
            return "checkmark.shield.fill"
        case .creativeCommonsBy, .creativeCommonsBySa, .creativeCommonsByNc:
            return "person.crop.circle.badge.checkmark"
        case .jamendoPersonal, .freeMusicArchive:
            return "globe.badge.chevron.backward"
        case .directAuthorized:
            return "link.badge.plus"
        case .streamOnly:
            return "waveform.badge.magnifyingglass"
        }
    }
    
    public var legalDescription: String {
        switch self {
        case .publicDomain, .creativeCommonsZero:
            return "Free for all uses worldwide without copyright restrictions. Offline playback & downloads are lawfully permitted."
        case .creativeCommonsBy:
            return "Lawfully downloadable and playable offline. You must provide appropriate credit to the creator."
        case .creativeCommonsBySa:
            return "Downloadable under Creative Commons Attribution-ShareAlike 4.0 terms."
        case .creativeCommonsByNc:
            return "Permitted for non-commercial personal playback and offline listening."
        case .jamendoPersonal:
            return "Legally licensed for personal streaming and offline listening through Jamendo Creative Commons catalog."
        case .freeMusicArchive:
            return "Curated under Free Music Archive lawful music sharing policies for open access."
        case .directAuthorized:
            return "Directly imported audio from authorized open media URLs or user's local personal file library."
        case .streamOnly:
            return "This media is authorized for preview and inline streaming only. Downloads are restricted."
        }
    }
}
