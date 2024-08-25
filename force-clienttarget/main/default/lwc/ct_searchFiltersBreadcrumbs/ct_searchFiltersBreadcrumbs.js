import { LightningElement, api } from "lwc";

export default class ct_searchFiltersBreadcrumbs extends LightningElement {
  @api isFirstStep;
  @api isActionSelectionStep;
  @api isReassignStep;
  @api isClientListCreatedStep;
  @api isExclusiveAccessStep;
  @api isEventAccessStep;

  //Return variable for use in Result list of Reassign step
  connectedCallback() {
    return this.isReassignStep;
  }

  steps;
  get currentStep() {
    if (this.isFirstStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Actions", value: "step-3" }
      ];
      return this.steps[0].value;
    } else if (this.isActionSelectionStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Actions", value: "step-3" }
      ];
      return this.steps[1].value;
    } else if (this.isReassignStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Reattach clients", value: "step-3" }
      ];
      return this.steps[2].value;
    } else if (this.isExclusiveAccessStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Access to Excl.sales", value: "step-3" }
      ];
      return this.steps[2].value;
    } else if (this.isClientListCreatedStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Client list created", value: "step-3" }
      ];
      return this.steps[2].value;
    } else if (this.isEventAccessStep) {
      this.steps = [
        { label: "Search Clients", value: "step-1" },
        { label: "Action Selection", value: "step-2" },
        { label: "Access to Excl.sales", value: "step-3" }
      ];
      return this.steps[2].value;
    }

    this.steps = [
      { label: "Search Clients", value: "step-1" },
      { label: "Action Selection", value: "step-2" },
      { label: "Access to Excl.sales", value: "step-3" }
    ];
    return this.steps[0].value;
  }
}