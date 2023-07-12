package kr.ac.kumoh.oiyo.mydiaryback.api;

import kr.ac.kumoh.oiyo.mydiaryback.domain.dto.WeatherDTO;
import kr.ac.kumoh.oiyo.mydiaryback.service.RegionService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

import static kr.ac.kumoh.oiyo.mydiaryback.domain.dto.WeatherDTO.*;

@RestController
@RequiredArgsConstructor
public class WeatherApiController {

    @Value("${weather.key}")
    private String weatherKey;

    @Value("${travel.key}")
    private String travelKey;

    private final RegionService regionService;

    /**
     * 맑음 지역 필터링
     * @return
     * @throws JSONException
     */
    @GetMapping("/weather/clear")
    public Response clearWeather () throws JSONException {
        List<ClearLocationInfoDTO> clearRegion = regionService.extractClearRegion();
        if (clearRegion == null || clearRegion.isEmpty()) return new Response("맑은 지역이 존재하지 않습니다.");
        return new Response(clearRegion);
    }

    /**
     *
     * @param mapX
     * @param mapY
     * @return
     */
    @GetMapping("/recommend")
    public Response recommendTravel(@RequestParam String mapX, @RequestParam String mapY) {
        String resultTravel = "";
        String apiUrl = "http://apis.data.go.kr/B551011/KorService/locationBasedList";
        List<TravelInfoDTO> travelDTOList = new ArrayList<>();

        StringBuilder urlBuilder = new StringBuilder(apiUrl);
        try {

            urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + travelKey);
            urlBuilder.append("&" + URLEncoder.encode("numOfRows", "UTF-8") + "=" + URLEncoder.encode("30", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("pageNo", "UTF-8") + "=" + URLEncoder.encode("1", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("MobileOS", "UTF-8") + "=" + URLEncoder.encode("ETC", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("MobileApp", "UTF-8") + "=" + URLEncoder.encode("5IYO", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("mapX", "UTF-8") + "=" + URLEncoder.encode(mapX, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("mapY", "UTF-8") + "=" + URLEncoder.encode(mapY, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("_type", "UTF-8") + "=" + URLEncoder.encode("json", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("arrange", "UTF-8") + "=" + URLEncoder.encode("E", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("radius", "UTF-8") + "=" + URLEncoder.encode("50000", "UTF-8"));

            URL url2 = new URL(urlBuilder.toString());

            HttpURLConnection conn = (HttpURLConnection) url2.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader rd;
            if (conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
                rd = new BufferedReader(new InputStreamReader(conn.getInputStream(),StandardCharsets.UTF_8));
            } else {
                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
            }

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                sb.append(line);
            }
            rd.close();
            conn.disconnect();

            resultTravel = sb.toString();

            // json
            JSONObject jsonObj = new JSONObject(resultTravel);
            JSONObject response = jsonObj.getJSONObject("response");

            JSONObject header = response.getJSONObject("header");
            JSONObject body = response.getJSONObject("body");

            JSONObject items = body.getJSONObject("items");

            JSONArray itemsJSONArray = items.getJSONArray("item");

            for (int j = 0; j < itemsJSONArray.length(); j++) {
                JSONObject itemObj = itemsJSONArray.getJSONObject(j);

                TravelInfoDTO infoDTO = new TravelInfoDTO();
                String title = itemObj.getString("title");
                String travelX = itemObj.getString("mapx");
                String travelY = itemObj.getString("mapy");

                infoDTO.setTitle(title);
                infoDTO.setX(travelX);
                infoDTO.setY(travelY);

                travelDTOList.add(infoDTO);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new Response(travelDTOList);
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    static class TravelInfoDTO {
        private String title;
        private String x;
        private String y;
    }



    @Data
    @AllArgsConstructor
    static class RecommendTravelDTO {
        private String title;
    }

    @Data
    @AllArgsConstructor
    static class Result<T> {
        private T result;
    }

    @Data
    @AllArgsConstructor
    static class Response<T> {
        private T response;
    }
}
