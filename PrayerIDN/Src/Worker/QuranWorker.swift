//
//  QuranWorker.swift
//  PrayerIDN
//
//  Created by Rangga Leo on 21/01/21.
//

import Foundation

struct QuranCacheMemory {
    static var request: [String: QuranResponse?] = [:]
}

internal class QuranWorker {
    static let shared = QuranWorker()
    
    
    func getQuran(surahNumber: Int? = nil, ayahNumber: [Int] = [], language: [QuranLanguage] = [], completion: @escaping (Result<QuranResponse, Error>, _ urlString: String) -> Void) {
        var url = URLConstant.api_quran + "surat"
        
        if let surah = surahNumber {
            let surahStr = String(describing: surah)
            url = url + "/" + surahStr
        }
        
        if ayahNumber.count > 0 {
            let mutatingAyahs = ayahNumber.sorted()
            let ayahStrings: [String] = mutatingAyahs.map{( String(describing: $0) )}
            let ayahStr = ayahStrings.joined(separator: ",")
            url = url + "/ayat/" + ayahStr
        }
        
        if language.count > 0 {
            let langStrings: [String] = language.map({ $0.rawValue })
            let langStr = langStrings.joined(separator: ",")
            url = url + "/bahasa/" + langStr
        }
        
        if
            let cache = QuranCacheMemory.request[url],
            let cacheResponse = cache {
            let result: Result<QuranResponse, Error> = .success(cacheResponse)
            completion(result, url)
            return
        }
        
        HTTPRequest.shared.connect(url: url, params: nil, model: QuranResponse.self) { (result) in
            completion(result, url)
        }
    }
    
}

public enum QuranLanguage: String, Codable {
    case al // albenian
    case ar // arabic
    case az // azerbaijani
    case en // english
    case tl // english transliteration
    case fr // french
    case de // germany
    case id // indonesia
    case idt // indonesia transliterasi
}

struct QuranResponse: Codable {
    let status: String
    let query: RequestQuery
    let bahasa: QuranLanguageRequest
    let surat: QuranSurat
    let ayat: QuranAyatRequest
}

struct QuranLanguageRequest: Codable {
    let proses: [QuranLanguage]
    let keterangan: [String]
}

struct QuranSurat: Codable {
    let nomor, nama, asma, name: String
    let start, ayat, type, urut: String
    let rukuk, arti, keterangan: String
}

struct QuranAyatRequest: Codable {
    let proses: [Int]
    let error: [Int]?
    let data: QuranAyatLanguage
}

struct QuranAyatLanguage: Codable {
    let al: [QuranAyat]? // albenian
    let ar: [QuranAyat]? // arabic
    let az: [QuranAyat]? // azerbaijani
    let en: [QuranAyat]? // english
    let tl: [QuranAyat]? // english transliteration
    let fr: [QuranAyat]? // french
    let de: [QuranAyat]? // germany
    let id: [QuranAyat]? // indonesia
    let idt: [QuranAyat]? // indonesia transliterasi
}

struct QuranAyat: Codable {
    let id, surat, ayat, teks: String
}

