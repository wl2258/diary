package kr.ac.kumoh.oiyo.mydiaryback.domain;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RegionRepository extends JpaRepository<Region, Long> {
    List<Region> findByWeatherState(String weatherState);
}
