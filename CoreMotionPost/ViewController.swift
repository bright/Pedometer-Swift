import UIKit
import CoreMotion
import Dispatch


class ViewController: UIViewController {

    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldStartUpdating: Bool = false
    private var startDate: Date? = nil

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var activityTypeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDate = startDate else { return }
        updateStepsCountLabelUsing(startDate: startDate)
    }

    @objc private func didTapStartButton() {
        shouldStartUpdating = !shouldStartUpdating

        let buttonTitle = shouldStartUpdating ? ("Stop") : ("Start")
        startButton.setTitle(buttonTitle, for: .normal)

        if shouldStartUpdating {
            startDate = Date()
            startUpdating()
        } else {
            stopUpdating()
        }
    }

    private func startUpdating() {
        startTrackingActivityType()
        startCountingSteps()
    }

    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
}


extension ViewController {
    private func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            DispatchQueue.main.async {
                self?.stepCountLabel.text = String(describing: pedometerData.numberOfSteps)
            }
        }
    }

    private func startTrackingActivityType() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) {
                [weak self] (activity: CMMotionActivity?) in

                guard let activity = activity else { return }
                DispatchQueue.main.async {
                    if activity.walking {
                        self?.activityTypeLabel.text = "Walking"
                    } else if activity.stationary {
                        self?.activityTypeLabel.text = "Stationary"
                    } else if activity.running {
                        self?.activityTypeLabel.text = "Running"
                    } else if activity.automotive {
                        self?.activityTypeLabel.text = "Automotive"
                    }
                }
            }
        }
    }

    private func startCountingSteps() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) {
                [weak self] pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                DispatchQueue.main.async {
                    self?.stepCountLabel.text = String(describing: pedometerData.numberOfSteps)
                }
            }
        }
    }
}