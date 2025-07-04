# finance-manager
This Canvas describes the `app_description_page.dart` file.  This page allows users to input annual income and categorized expenditures (housing, food, transport, entertainment). It dynamically displays a pie chart of the expenditure breakdown using `fl_chart`, complete with animation. Data is saved and passed to the home page for state management.
This Flutter application, as detailed in the provided Canvas, serves as an "Activity Logger" with a robust financial tracking component.

The app initiates with a **Login Page**, designed for user authentication, although the current implementation focuses on the UI flow rather than backend validation. Upon successful (simulated) login, users are directed to the **Home Page**, which acts as the central navigation hub.

From the Home Page, users can seamlessly transition between two primary sections via a **side panel (Drawer)**:

1.  **Add Activity Page:** This section allows users to meticulously log their daily activities. For each activity, they can input a descriptive name, add optional details, and precisely mark the date and time. This feature aims to help users keep a detailed record of their engagements.

2.  **Financial Overview Page:** This is where the app's financial tracking capabilities come to life. Users can input their annual income and total annual expenditure. Crucially, they can also break down their spending into specific categories such as housing, food, transport, and entertainment. The app then intelligently processes this data to present a clear **Expenditure Breakdown** in the form of a dynamic **Pie Chart**. This chart is displayed prominently above the input fields, offering an immediate visual summary of where their money is being allocated. The pie chart also features a subtle animation, enhancing the user experience as data is updated. A clear legend accompanies the chart, ensuring easy interpretation of each expenditure category.

The app's structure, with its clear separation of concerns (login, activity logging, financial tracking), and its intuitive navigation via the Drawer, aims to provide a user-friendly experience for personal activity and financial management. While the current version focuses on the front-end, it lays a solid foundation for future integration with persistent data storage solutions.
