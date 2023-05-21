import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("Hello World")

    property Camera previousCamera: null
    property CaptureSession previousCaptureSession: null
    property VideoOutput previousVideoOutput: null

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
        onCameraChanged: {
            camera.active = true
        }
    }

    Item {
        id: videoItem
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
                previousCaptureSession = captureSession
                for (var i = 0; i < mediaDevices.videoInputs.length; i++) {
                    this.append({ description: mediaDevices.videoInputs[i].description })
                }
            }
        }
        textRole: "description"
        displayText: previousCaptureSession.camera.cameraDevice.description
        onActivated: function (index) {
            if (previousCamera != null
                    && previousCamera.cameraDevice.description !== mediaDevices.videoInputs[index].description) {
                if (previousCamera.active) {
                    previousCamera.stop()
                }
                if (previousCaptureSession != null) {
                    previousCaptureSession.destroy()
                }
                if (previousVideoOutput == null) {
                    videoOutput.destroy()
                } else {
                    previousVideoOutput.destroy()
                }
                previousVideoOutput = Qt.createQmlObject(`
                    import QtMultimedia
                    VideoOutput {
                        anchors.fill: parent
                    }
                `, videoItem, "vi")
                previousCaptureSession = Qt.createQmlObject(`
                    import QtMultimedia
                    CaptureSession {
                        camera: Camera {
                            cameraDevice: mediaDevices.videoInputs[${index}]
                            active: true
                        }
                        onCameraChanged: {
                            camera.active = true
                        }
                    }
                `, mainWindow, "cs")
                previousCaptureSession.videoOutput = previousVideoOutput
                previousCamera = previousCaptureSession.camera
            }
        }
    }
}
