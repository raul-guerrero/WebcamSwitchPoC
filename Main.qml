import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

Window {
    width: 800
    height: 600
    visible: true
    title: qsTr("Hello World")

    property Camera previousCamera: null

    MediaDevices {
        id: mediaDevices
    }

    CaptureSession {
        id: captureSession
        videoOutput: videoOutput
        camera: Camera {
            cameraDevice: mediaDevices.defaultVideoInput
            active: true
        }
    }

    Item {
        x: 20
        y: 20
        width: 640
        height: 480

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }
    }

    ComboBox {
        id: combobox_select_camera
        x: 670
        y: 20
        width: 110
        height: 32
        model: ListModel {
            Component.onCompleted: function() {
                previousCamera = captureSession.camera
                for (var i = 0; i < mediaDevices.videoInputs.length; i++) {
                    this.append({ description: mediaDevices.videoInputs[i].description })
                }
            }
        }
        textRole: "description"
        displayText: captureSession.camera.cameraDevice.description
        onActivated: function (index) {
            if (previousCamera != null && previousCamera.active) {
                previousCamera.stop()
            }
            videoOutput.visible = false
            captureSession.camera.cameraDevice = mediaDevices.videoInputs[index]
            previousCamera = captureSession.camera
            videoOutput.visible = true
            captureSession.camera.start()
        }
    }
}
