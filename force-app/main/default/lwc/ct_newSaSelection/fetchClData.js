const recordMetadata = {
  name: "name",
  segmentation: "segmentation",
  last_3yr_income: "last_3yr_income",
  last_transaction: "last_transaction",
  dream_id: "dream_id",
  assigned_ca: "assigned_ca",
  ca_to_assign: "ca_to_assign"
};
let mockResponse;

export default function fetchClData({ amountOfRecords }) {
  fetch("https://data-faker.herokuapp.com/collection", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8"
    },
    body: JSON.stringify({
      amountOfRecords,
      recordMetadata
    })
  })
    .then((response) => response.json())
    .catch((e) => console.log(`Fetch CL is not connected to real API: ${e}`))
    .finally(
      (mockResponse = Promise.resolve([
        {
          id:"0",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Technical User",
          ca_to_assign: ""
        },
        {
          id:"1",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Technical User",
          ca_to_assign: ""
        },
        {
          id:"2",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"3",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"4",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"5",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"6",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"7",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"8",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"9",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        },
        {
          id:"10",
          name: "Deborah ROSEN",
          segmentation: "Potential 10K",
          last_3yr_income: "46159",
          last_transaction: "2021-07-18T18:44:03.208Z",
          dream_id: "21614413",
          assigned_ca: "Valdemar Forsberg",
          ca_to_assign: ""
        }
      ]))
    );
  return mockResponse;
}