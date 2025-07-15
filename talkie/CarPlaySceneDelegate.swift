import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        let item = CPListItem(text: "Hello", detailText: "World")
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Talkie", sections: [section])
        interfaceController.setRootTemplate(listTemplate, animated: true)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}
