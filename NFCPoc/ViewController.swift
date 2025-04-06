
import CoreBluetooth
import CoreNFC
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var toSendText: UITextField!
    @IBOutlet weak var sendWithBluetoothAction: UIButton!
    @IBOutlet weak var sendWithNFCAction: UIButton!

    var nfcSession: NFCTagReaderSession?
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil) // Configure bluetooth manager
    }

    func enviarTextoPorBluetooth(texto: String) {
        if let data = texto.data(using: .utf8) {
            // Enviar data al peripheral.
        }
    }

    func iniciarLecturaNFC() {
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Acerca tu dispositivo NFC"
        nfcSession?.begin()
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // El Bluetooth está encendido, puedes comenzar a buscar dispositivos
        } else {
            // El Bluetooth no está encendido
        }
    }
}

extension ViewController: NFCTagReaderSessionDelegate {
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if let firstTag = tags.first {
            session.connect(to: firstTag) { (error) in
                if error != nil {
                    session.invalidate(errorMessage: "Error al conectar con el tag")
                    return
                }
                switch firstTag {
                case .iso15693(let tag):
                    let payload = NFCNdefPayload(wellKnownTypeTextPayload: self.toSendText.text ?? "", locale: Locale.current)
                    let ndefMessage = NFCNdefMessage(records: [payload!])
                    tag.writeNDEF(ndefMessage) { (error) in
                        if error != nil {
                            session.invalidate(errorMessage: "Error al escribir en el tag")
                        } else {
                            session.invalidate(errorMessage: "Se escribio correctamente en el tag")
                        }
                    }
                case .feliCa(let tag):
                    let payload = NFCNdefPayload(wellKnownTypeTextPayload: self.toSendText.text ?? "", locale: Locale.current)
                    let ndefMessage = NFCNdefMessage(records: [payload!])
                    tag.writeNDEF(ndefMessage) { (error) in
                        if error != nil {
                            session.invalidate(errorMessage: "Error al escribir en el tag")
                        } else {
                            session.invalidate(errorMessage: "Se escribio correctamente en el tag")
                        }
                    }
                default:
                    session.invalidate(errorMessage: "Tag no soportado")
                    return
                }
            }
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // Manejar errores de la sesión NFC
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Sesión NFC activa")
    }
}
