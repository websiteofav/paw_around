/// Indian states/UTs mapped to their major cities.
/// Used in UserProfileSetupScreen for location selection.
class IndiaLocations {
  static const Map<String, List<String>> statesAndCities = {
    'Andhra Pradesh': [
      'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool',
      'Kakinada', 'Tirupati', 'Rajamahendravaram', 'Kadapa', 'Eluru',
    ],
    'Arunachal Pradesh': [
      'Itanagar', 'Naharlagun', 'Pasighat', 'Tawang', 'Ziro',
    ],
    'Assam': [
      'Guwahati', 'Dibrugarh', 'Jorhat', 'Silchar', 'Tezpur',
      'Nagaon', 'Tinsukia', 'Bongaigaon',
    ],
    'Bihar': [
      'Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga',
      'Purnia', 'Arrah', 'Bihar Sharif', 'Begusarai',
    ],
    'Chhattisgarh': [
      'Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg',
      'Rajnandgaon', 'Jagdalpur', 'Ambikapur',
    ],
    'Goa': [
      'Panaji', 'Margao', 'Vasco da Gama', 'Mapusa', 'Ponda',
      'Bicholim', 'Curchorem',
    ],
    'Gujarat': [
      'Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar',
      'Jamnagar', 'Junagadh', 'Gandhinagar', 'Anand', 'Nadiad',
    ],
    'Haryana': [
      'Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Yamunanagar',
      'Rohtak', 'Hisar', 'Karnal', 'Sonipat', 'Panchkula',
    ],
    'Himachal Pradesh': [
      'Shimla', 'Manali', 'Dharamshala', 'Solan', 'Mandi',
      'Kullu', 'Hamirpur', 'Una', 'Baddi',
    ],
    'Jharkhand': [
      'Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar',
      'Hazaribagh', 'Giridih', 'Ramgarh',
    ],
    'Karnataka': [
      'Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi',
      'Davangere', 'Ballari', 'Tumkur', 'Shivamogga', 'Vijayapura',
    ],
    'Kerala': [
      'Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam',
      'Palakkad', 'Malappuram', 'Kannur', 'Kottayam', 'Alappuzha',
    ],
    'Madhya Pradesh': [
      'Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain',
      'Sagar', 'Dewas', 'Satna', 'Ratlam', 'Rewa',
    ],
    'Maharashtra': [
      'Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad',
      'Solapur', 'Amravati', 'Kolhapur', 'Nanded', 'Thane',
      'Kalyan', 'Vasai-Virar', 'Sangli', 'Jalgaon',
    ],
    'Manipur': [
      'Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur', 'Ukhrul',
    ],
    'Meghalaya': [
      'Shillong', 'Tura', 'Nongstoin', 'Jowai',
    ],
    'Mizoram': [
      'Aizawl', 'Lunglei', 'Champhai', 'Kolasib',
    ],
    'Nagaland': [
      'Kohima', 'Dimapur', 'Mokokchung', 'Tuensang',
    ],
    'Odisha': [
      'Bhubaneswar', 'Cuttack', 'Rourkela', 'Brahmapur', 'Sambalpur',
      'Puri', 'Balasore', 'Bhadrak', 'Baripada',
    ],
    'Punjab': [
      'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda',
      'Mohali', 'Pathankot', 'Hoshiarpur', 'Moga', 'Firozpur',
    ],
    'Rajasthan': [
      'Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer',
      'Bikaner', 'Bhilwara', 'Alwar', 'Sikar', 'Bharatpur',
    ],
    'Sikkim': [
      'Gangtok', 'Namchi', 'Geyzing', 'Mangan',
    ],
    'Tamil Nadu': [
      'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem',
      'Tirunelveli', 'Tiruppur', 'Erode', 'Vellore', 'Thoothukudi',
    ],
    'Telangana': [
      'Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam',
      'Ramagundam', 'Mahbubnagar', 'Nalgonda',
    ],
    'Tripura': [
      'Agartala', 'Udaipur', 'Dharmanagar', 'Kailashahar',
    ],
    'Uttar Pradesh': [
      'Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Prayagraj',
      'Meerut', 'Ghaziabad', 'Noida', 'Mathura', 'Aligarh',
      'Bareilly', 'Moradabad', 'Saharanpur', 'Gorakhpur',
    ],
    'Uttarakhand': [
      'Dehradun', 'Haridwar', 'Roorkee', 'Haldwani', 'Rishikesh',
      'Kashipur', 'Rudrapur', 'Nainital',
    ],
    'West Bengal': [
      'Kolkata', 'Asansol', 'Siliguri', 'Durgapur', 'Bardhaman',
      'Malda', 'Barasat', 'Howrah', 'Kharagpur',
    ],
    // Union Territories
    'Andaman and Nicobar Islands': ['Port Blair', 'Diglipur', 'Car Nicobar'],
    'Chandigarh': ['Chandigarh'],
    'Dadra & Nagar Haveli and Daman & Diu': ['Silvassa', 'Daman', 'Diu'],
    'Delhi': ['New Delhi', 'Delhi', 'Dwarka', 'Rohini', 'Noida Extension'],
    'Jammu and Kashmir': [
      'Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Sopore',
    ],
    'Ladakh': ['Leh', 'Kargil'],
    'Lakshadweep': ['Kavaratti', 'Agatti', 'Minicoy'],
    'Puducherry': ['Puducherry', 'Karaikal', 'Mahe', 'Yanam'],
  };

  static List<String> get states => statesAndCities.keys.toList()..sort();

  static List<String> citiesForState(String state) =>
      statesAndCities[state] ?? [];
}
