package cn.tdx.framework.license.core.dataobject;

import cn.hutool.core.io.resource.ClassPathResource;
import de.schlichtherle.license.AbstractKeyStoreParam;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 自定义KeyStoreParam
 *
 * @author zwj
 */
public class CustomKeyStoreParam extends AbstractKeyStoreParam {

    /**
     * 公钥/私钥在磁盘上的存储路径
     */
    private final String storePath;
    /**
     * 别名*
     */
    private final String alias;
    /**
     * 公钥访问秘钥*
     */
    private final String storePwd;
    /**
     * 私钥访问秘钥*
     */
    private final String keyPwd;
    /**
     * 是否为绝对路径*
     */
    private final Boolean isAbs;

    public CustomKeyStoreParam(Class clazz, String resource, String alias, String storePwd, String keyPwd, Boolean isAbs) {
        super(clazz, resource);
        this.storePath = resource;
        this.alias = alias;
        this.storePwd = storePwd;
        this.keyPwd = keyPwd;
        this.isAbs = isAbs;
    }


    @Override
    public String getAlias() {
        return alias;
    }

    @Override
    public String getStorePwd() {
        return storePwd;
    }

    @Override
    public String getKeyPwd() {
        return keyPwd;
    }

    /**
     * 重写getStream()方法
     *
     * @return InputStream
     * @throws IOException IOException
     */
    @Override
    public InputStream getStream() throws IOException {
        InputStream in;
        if (isAbs) {
            Path path = Paths.get(storePath);
            in = Files.newInputStream(path);
        } else {
            in = new ClassPathResource(storePath).getStream();
        }
        if (null == in) {
            throw new FileNotFoundException(storePath);
        }
        return in;
    }
}

