let clientAdvisors;

export default function fetchCaData({ amountOfRecords }) {
  fetch("https://data-faker.herokuapp.com/collection", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8"
    },
    body: JSON.stringify({
      amountOfRecords
    })
  })
    .then((response) => response.json())
    .catch((e) => console.log(`Fetch CA is not connected to real API: ${e}`))
    .finally(
      (clientAdvisors = Promise.resolve([
        {
          id: "0",
          name: "Sami Al Saad",
          clientsAmount: "1456",
          options: [
            {
              label: "Sami Al Saad",
              value: "Sami Al Saad"
            }
          ]
        },
        {
          id: "1",
          name: "Farid Aminov",
          clientsAmount: "123",
          options: [
            {
              label: "Farid Aminov",
              value: "Farid Aminov"
            }
          ]
        },
        {
          id: "2",
          name: "Marie Cambiero",
          clientsAmount: "452",
          options: [
            {
              label: "Marie Cambiero",
              value: "Marie Cambiero"
            }
          ]
        },
        {
          id: "3",
          name: "Philipe Durand",
          clientsAmount: "641",
          options: [
            {
              label: "Philipe Durand",
              value: "Philipe Durand"
            }
          ]
        },
        {
          id: "4",
          name: "Yosef Shulman",
          clientsAmount: "1234",
          options: [
            {
              label: "Yosef Shulman",
              value: "Yosef Shulman"
            }
          ]
        },
        {
          id: "5",
          name: "Rachel Atlant",
          clientsAmount: "2345",
          options: [
            {
              label: "Rachel Atlant",
              value: "Rachel Atlant"
            }
          ]
        }
      ]))
    );
  return clientAdvisors;
}