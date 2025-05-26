//
//  PhotoMapper.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

struct PhotoMapper {
    static func toDomain(_ dto: PhotoInfoDTO) -> SharedPhoto {
        return SharedPhoto(
            photoId: dto.photoId,
            familyId: dto.familyId,
            photoUrl: dto.photoUrl,
            uploadedBy: dto.uploadedBy,
            uploadedAt: parseServerDate(from: dto.uploadedAt),
            deleted: dto.deleted,
            deletedAt: dto.deletedAt != nil ? parseServerDate(from: dto.deletedAt!) : nil
        )
    }

    static func toDTO(_ domain: SharedPhoto) -> PhotoInfoDTO {
        let dateFormatter = ISO8601DateFormatter()
        return PhotoInfoDTO(
            photoId: domain.photoId,
            familyId: domain.familyId,
            photoUrl: domain.photoUrl,
            uploadedBy: domain.uploadedBy,
            uploadedAt: dateFormatter.string(from: domain.uploadedAt),
            deleted: domain.deleted,
            deletedAt: domain.deletedAt != nil ? dateFormatter.string(from: domain.deletedAt!) : nil
        )
    }

    static func toDomainArray(_ dtos: [PhotoInfoDTO]) -> [SharedPhoto] {
        return dtos.map(toDomain)
    }

    private static func parseServerDate(from dateString: String) -> Date {
        guard !dateString.isEmpty else {
            return Date()
        }

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        let iso8601Formatter = ISO8601DateFormatter()
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }

        return Date()
    }
}
