import Foundation

struct StorageService {
    
    enum StorageError: Error {
        case noFilePathError(String)
    }
    
    func getControlPanel(from fileName: String) -> [ControlPanelSection] {
        
        if let controls: [ControlPanelSection] = decodeJson(at: fileName)  {
            return controls
        }
        
        return []
    }
    
    func getPermissionDialogue(from fileName: String) -> PermissionDialogue? {
        let permissionConfiguration: PermissionDialogue = decodeJson(at: fileName)
        return permissionConfiguration
    }
    
    func getLocalScheduler(from fileName: String) -> LocalScheduler? {
        let localNotificationConfiguration: LocalScheduler = decodeJson(at: fileName)
        return localNotificationConfiguration
    }
        
    func decodeJson<T: Decodable> (at path: String) -> T {

        var result: T!
        print("path:", path)
        
        do {
            
            let filePath: URL
            if let mainFilePath = Bundle.main.url(forResource: path, withExtension: "json") {
                filePath = mainFilePath
            } else {
                throw StorageError.noFilePathError("Couldn't initialize the filePath")
            }
            
            print("filePath:", filePath)
            
            let data = try Data(contentsOf: filePath)
            print("pathData:", data)
            result = try JSONDecoder().decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
        return result
    }
    
}

