import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Drive

class GoogleDriveService {
    private let service = GTLRDriveService()

    init() {
        self.service.authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
    }

    func findOrCreateFolder(name: String, completion: @escaping (String?, Error?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.folder' and name='\(name)' and trashed=false"
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            if let folder = (result as? GTLRDrive_FileList)?.files?.first {
                completion(folder.identifier, nil)
            } else {
                let folder = GTLRDrive_File()
                folder.name = name
                folder.mimeType = "application/vnd.google-apps.folder"

                let createQuery = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
                self.service.executeQuery(createQuery) { (ticket, file, error) in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion((file as? GTLRDrive_File)?.identifier, nil)
                    }
                }
            }
        }
    }

    func uploadFile(name: String, fileURL: URL, folderID: String, completion: @escaping (String?, Error?) -> Void) {
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]

        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: "audio/m4a")
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)

        service.executeQuery(query) { (ticket, file, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion((file as? GTLRDrive_File)?.identifier, nil)
            }
        }
    }
}
