package kr.ac.kumoh.oiyo.mydiaryback.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
public class WeatherDTO {
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class PosDTO {
        private String x;
        private String y;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ClearLocationInfoDTO {
        private String temp;
        private String location;
        private PosDTO position;
    }
}
