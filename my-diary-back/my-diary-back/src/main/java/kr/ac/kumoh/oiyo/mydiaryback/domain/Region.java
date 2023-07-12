package kr.ac.kumoh.oiyo.mydiaryback.domain;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Entity
@Table(name = "Region")
@NoArgsConstructor
@Getter
public class Region extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "REGION_ID")
    private Long id;
    @Column(name = "REGION_EN_NAME")
    private String regionEnName;
    @Column(name = "REGION_KO_NAME")
    private String regionKoName;
    @Column(name = "TEMPERATURE")
    private String temperature;
    @Column(name = "WEATHER_STATE")
    private String weatherState;
    @Column(name = "REGION_X_POS")
    private String posX;
    @Column(name = "REGION_Y_POS")
    private String posY;

    @Builder
    public Region(String regionEnName, String regionKoName, String temperature, String weatherState, String posX, String posY) {
        this.regionEnName = regionEnName;
        this.regionKoName = regionKoName;
        this.temperature = temperature;
        this.weatherState = weatherState;
        this.posX = posX;
        this.posY = posY;
    }

    public void setTemperature(String temperature) {
        this.temperature = temperature;
    }

    public void setWeatherState(String weatherState) {
        this.weatherState = weatherState;
    }

    public void setRegionPos(String posX, String posY) {
        this.posX = posX;
        this.posY = posY;
    }
}
