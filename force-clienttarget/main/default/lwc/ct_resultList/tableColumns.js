export const regularColumns = [
    {
      label: "Name",
      fieldName: "linkToClientAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "name" },
        tooltip: "Name",
        target: "_blank"
      }
    },
    { label: "12MR", fieldName: "purchasePeriod" },
    { label: "Last Transaction", fieldName: "lastTransaction", type: "date" },
    {
      label: "DreamID",
      fieldName: "dreamId",
      cellAttributes: { alignment: "left" }
    },
    {
      label: "Preferred CA",
      fieldName: "linkToCaAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "preferredCa" },
        tooltip: "Preferred CA",
        target: "_blank"
      }
    },
    { label: "Attached Store", fieldName: "attachedStore" },
    { label: "Country/Region", fieldName: "country" },
    {
      type: 'action',
      typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] },
    },
];

export const reattachColumns = [
    {
      label: "Name",
      fieldName: "linkToClientAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "name" },
        tooltip: "Name",
        target: "_blank"
      }
    },
    // { label: "Segmentation", fieldName: "segmentation" },
    { label: "12MR", fieldName: "purchasePeriod" },
    { label: "Last Transaction", fieldName: "lastTransaction", type: "date" },
    {
      label: "DreamID",
      fieldName: "dreamId",
      cellAttributes: { alignment: "left" }
    },
    {
      label: "Preferred CA",
      fieldName: "linkToCaAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "preferredCa" },
        tooltip: "Preferred CA",
        target: "_blank"
      }
    },
    {
      label: "New preferred CA",
      fieldName: "caToAssign",
      type: "text"
    },
    {
      type: 'action',
      typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] },
    }
];

export const campaignColumns = [
    {
      label: "Name",
      fieldName: "linkToClientAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "name" },
        tooltip: "Name",
        target: "_blank"
      }
    },
    { label: "12MR", fieldName: "purchasePeriod" },
    { label: "Last Transaction", fieldName: "lastTransaction", type: "date" },
    {
      label: "DreamID",
      fieldName: "dreamId",
      cellAttributes: { alignment: "left" }
    },
    { label: "Segmentation", fieldName: "segmentation" },
    {
      label: "Campaign CA",
      fieldName: "linkToCaAccount",
      type: "url",
      typeAttributes: {
        label: { fieldName: "preferredCa" },
        tooltip: "Campaign CA",
        target: "_blank"
      }
    },
    {
      label: "New Campaign CA",
      fieldName: "caToAssign",
      type: "text"
    },
    {
      type: 'action',
      typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] },
    }
];