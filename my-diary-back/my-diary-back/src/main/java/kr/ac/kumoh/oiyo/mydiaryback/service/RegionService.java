package kr.ac.kumoh.oiyo.mydiaryback.service;

import kr.ac.kumoh.oiyo.mydiaryback.domain.Region;
import kr.ac.kumoh.oiyo.mydiaryback.domain.RegionRepository;
import kr.ac.kumoh.oiyo.mydiaryback.domain.dto.WeatherDTO.PosDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Collectors;

import static kr.ac.kumoh.oiyo.mydiaryback.domain.dto.WeatherDTO.*;

@Service
@RequiredArgsConstructor
@EnableAsync
@Slf4j
public class RegionService {
    @Value("${weather.key}")
    private String weatherKey;

    @Value("${travel.key}")
    private String travelKey;
    private final RegionRepository regionRepository;

    @Transactional
    @Scheduled(cron="0 0 */1 * * *")
    public void weatherState() {
        log.info("날씨 api 호출");
        String url = "https://api.openweathermap.org/data/2.5/weather";

        try {
            List<Region> regionList = regionRepository.findAll();
            for (Region region : regionList) {
                StringBuilder urlStringBuilder = new StringBuilder(url);

                urlStringBuilder.append("?" + URLEncoder.encode("q", "UTF-8") + "=" + URLEncoder.encode(region.getRegionEnName(), "UTF-8"));
                urlStringBuilder.append("&" + URLEncoder.encode("appid", "UTF-8") + "=" + weatherKey);
                urlStringBuilder.append("&" + URLEncoder.encode("units", "UTF-8") + "=" + URLEncoder.encode("metric", "UTF-8"));

                URL url1 = new URL(urlStringBuilder.toString());

                HttpURLConnection urlConnection = (HttpURLConnection) url1.openConnection();
                urlConnection.setRequestMethod("GET");

                BufferedReader br;

                if (urlConnection.getResponseCode() >= 200 && urlConnection.getResponseCode() <= 300) {
                    br = new BufferedReader(new InputStreamReader(urlConnection.getInputStream(), StandardCharsets.UTF_8));
                } else {
                    br = new BufferedReader(new InputStreamReader(urlConnection.getErrorStream(), StandardCharsets.UTF_8));
                }

                // 날씨 api 반환 결과
                StringBuilder result = new StringBuilder();
                String returnLine;
                while ((returnLine = br.readLine()) != null) {
                    result.append(returnLine);
                }

                br.close();
                urlConnection.disconnect();

                JSONObject jsonObj = new JSONObject(result.toString());
                JSONObject coordObj = jsonObj.getJSONObject("coord");

                BigDecimal mapX = coordObj.getBigDecimal("lon");
                BigDecimal mapY = coordObj.getBigDecimal("lat");

                region.setRegionPos(mapX.toString(), mapY.toString());

                JSONArray weatherArray = jsonObj.getJSONArray("weather");

                JSONObject tempArray = jsonObj.getJSONObject("main");

                for (int i = 0; i < weatherArray.length(); i++) {
                    JSONObject weatherObj = weatherArray.getJSONObject(i);
                    String weather = weatherObj.getString("main");
                    region.setWeatherState(weather);

                    BigDecimal temp = tempArray.getBigDecimal("temp");
                    region.setTemperature(temp.toString());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ClearLocationInfoDTO> extractClearRegion() {
        List<Region> clearRegionList = regionRepository.findByWeatherState("Clear");
        if (clearRegionList == null || clearRegionList.isEmpty()) return null;
        List<ClearLocationInfoDTO> clearLocationList = clearRegionList.stream()
                .map(r -> new ClearLocationInfoDTO(r.getTemperature(), r.getRegionKoName(), new PosDTO(r.getPosX(), r.getPosY())))
                .collect(Collectors.toList());

        return clearLocationList;
    }
}
