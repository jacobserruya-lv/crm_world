import { LightningElement } from "lwc";

export default class Ct_clientFilters extends LightningElement {
  genderValue = "Select an Option";
  segmentationValue = ["50K_chekbox"];
  contactableValue = [];

  get genderOptions() {
    return [
      { label: "Male", value: "male_option" },
      { label: "Female", value: "female_option" }
    ];
  }

  get segmentationOptions() {
    return [
      { label: "50K", value: "50K_chekbox" },
      { label: "Potential 10K", value: "p10K_chekbox" },
      { label: "10K This Year", value: "10K_YTD_chekbox" },
      { label: "Prospects", value: "prospects_chekbox" }
    ];
  }

  get contactableOptions() {
    return [
      { label: "At least one channel", name: "atLeastOne_chekbox" },
      { label: "SMS/Chat App", name: "smsChat_chekbox" },
      { label: "Phone", name: "phone_chekbox" },
      { label: "Email", name: "email_chekbox" }
    ];
  }

  handleGenderChange(event) {
    this.genderValue = event.detail.value;
  }

  get selectedSegmentationValues() {
    return this.segmentationValue.join(",");
  }

  handleSegmentationChange(event) {
    this.segmentationValue = event.detail.value;
  }

  get selectedContactableValues() {
    return this.contactableValue.join(",");
  }

  handleContactableChange(event) {
    let options = this.contactableValue;
    let value = event.target.name;
    if (options.includes(value))
      this.contactableValue = options.filter((option) => option !== value);
    else options.push(value);
  }
}