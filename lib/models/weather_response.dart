
class WeatherResponse {
  final CurrentWeather current;
  final Map<String, MinutelyWeather> minutely15;

  WeatherResponse({
    required this.current,
    required this.minutely15,
  });

  factory WeatherResponse.fromAPIJson(Map<String, dynamic> json) {
    return WeatherResponse(
        current: CurrentWeather.fromAPIJson(json['current']),
        minutely15: parseMinutely15FromAPIJson(json)
      );
  }
  factory WeatherResponse.fromInternalJson(Map<String, dynamic> json){
    return WeatherResponse(
      current: CurrentWeather.fromInternalJson(json['current']),
      minutely15: parseMinutely15FromInternalJson(json),
    );
  }

  Map<String, dynamic> toInternalJson() {
    return {
      'current': current.toInterlanJson(),
      'minutely_15': getMinutely15IntenalJson()
    };
  }
  Map<String, dynamic> getMinutely15IntenalJson(){
    return minutely15.map((key,value) => 
      MapEntry(key, {'temperature': value.temperature, 'precipitation': value.precipitation}));
  }
  static Map<String,MinutelyWeather> parseMinutely15FromAPIJson(Map<String, dynamic> json){
    final minutely = json['minutely_15'];

    final times = List<String>.from(minutely['time']);

    final temperatures = List<double>.from(
      minutely['temperature_2m'].map(
        (value) => (value as num).toDouble(),
      ),
    );
    final precipitations = List<double>.from(
      minutely['precipitation'].map(
        (value) => (value as num).toDouble(),
      ),
    );

    final temperature = <String, MinutelyWeather>{};

    for (int i = 0; i < times.length; i++) {
      temperature[times[i]] = MinutelyWeather(temperature: temperatures[i], precipitation: precipitations[i]);
    }
    return temperature;
  }
  
  static Map<String,MinutelyWeather> parseMinutely15FromInternalJson(Map<String, dynamic> json){
    final minutely = json['minutely_15'] as Map<String, dynamic>;
    return minutely.map((key,value) => 
      MapEntry(key, MinutelyWeather(temperature: value['temperature'] as double, precipitation: value['precipitation'] as double)));
  }
}

class MinutelyWeather{
  final double temperature;
  final double precipitation;
  MinutelyWeather({
    required this.temperature,
    required this.precipitation
  });
}
class CurrentWeather {
  final double temperature;
  final double precipitation;
  final int humidity;

  CurrentWeather({
    required this.temperature,
    required this.precipitation,
    required this.humidity,
  });

  factory CurrentWeather.fromAPIJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] ?? 0) as int,
    );
  }
  factory CurrentWeather.fromInternalJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temperature_2m'] as double,
      precipitation: json['precipitation'] as double,
      humidity: json['relative_humidity_2m'] as int,
    );
  }

  Map<String, dynamic> toInterlanJson() {
    return {
      'temperature_2m': temperature,
      'precipitation': precipitation,
      'relative_humidity_2m': humidity,
    };
  }
}