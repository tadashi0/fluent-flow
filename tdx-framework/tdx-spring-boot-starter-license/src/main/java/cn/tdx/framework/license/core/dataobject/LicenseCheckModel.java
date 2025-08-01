package cn.tdx.framework.license.core.dataobject;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * License校验实体类
 *
 * @author zwj
 */
@Data
public class LicenseCheckModel implements Serializable {
    /**
     * 可被允许的IP地址
     */
    private List<String> ipAddress;

    /**
     * 可被允许的MAC地址
     */
    private List<String> macAddress;

    /**
     * 可被允许的CPU序列号
     */
    private String cpuSerial;

    /**
     * 可被允许的主板序列号
     */
    private String mainBoardSerial;

    @Override
    public String toString() {
        return "{" +
                "ipAddress=" + ipAddress +
                ", macAddress=" + macAddress +
                ", cpuSerial='" + cpuSerial + '\'' +
                ", mainBoardSerial='" + mainBoardSerial + '\'' +
                '}';
    }
}
