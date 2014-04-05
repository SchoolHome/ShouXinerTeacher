#include "amrFileCodec.h"
#include "interf_enc.h"
#include "interf_dec.h"

#include <stdio.h>
#include <memory.h>

int amrEncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200}; // amr ���뷽ʽ

// ��WAVE�ļ�������WAVE�ļ�ͷ��ֱ�ӵ�PCM��Ƶ����
void SkipToPCMAudioData(FILE* fpwave)
{
    RIFFHEADER riff;
    FMTBLOCK fmt;
    XCHUNKHEADER chunk;
    WAVEFORMATX wfx;
    int bDataBlock = 0;
	

    // 1. ��RIFFͷ
    fread(&riff, 1, sizeof(RIFFHEADER), fpwave);

    // 2. ��FMT�� - ��� fmt.nFmtSize>16 ˵����Ҫ����һ��������Сû�ж�
    fread(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    if ( chunk.nChunkSize>16 )
    {
        fread(&wfx, 1, sizeof(WAVEFORMATX), fpwave);
    }
    else
    {
        memcpy(fmt.chFmtID, chunk.chChunkID, 4);
        fmt.nFmtSize = chunk.nChunkSize;
        fread(&fmt.wf, 1, sizeof(WAVEFORMAT), fpwave);
    }

    // 3.ת��data�� - ��Щ����fact��ȡ�
    while(!bDataBlock)
    {
        fread(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
        if ( !memcmp(chunk.chChunkID, "data", 4) )
        {
            bDataBlock = 1;
            break;
        }
        // ��Ϊ�������data��,������������
        fseek(fpwave, chunk.nChunkSize, SEEK_CUR);
    }
}

// ��WAVE�ļ���һ��������PCM��Ƶ֡
// ����ֵ: 0-���� >0: ����֡��С



int ReadPCMFrame(short speech[], FILE* fpwave, int nChannels, int nBitsPerSample)
{
    int nRead = 0;
    int x = 0, y=0;
    //unsigned short ush1=0, ush2=0, ush=0;

    // ԭʼPCM��Ƶ֡����
    unsigned char pcmFrame_8b1[PCM_FRAME_SIZE];
    unsigned char pcmFrame_8b2[PCM_FRAME_SIZE<<1];
    unsigned short pcmFrame_16b1[PCM_FRAME_SIZE];
    unsigned short pcmFrame_16b2[PCM_FRAME_SIZE<<1];

    if (nBitsPerSample==8 && nChannels==1)
    {
        nRead = fread(pcmFrame_8b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
        for(x=0; x<PCM_FRAME_SIZE; x++)
        {
            speech[x] =(short)((short)pcmFrame_8b1[x] << 7);
        }
    }
    else
        if (nBitsPerSample==8 && nChannels==2)
        {
            nRead = fread(pcmFrame_8b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
            for( x=0, y=0; y<PCM_FRAME_SIZE; y++,x+=2 )
            {
                // 1 - ȡ��������֮������
                speech[y] =(short)((short)pcmFrame_8b2[x+0] << 7);
                // 2 - ȡ��������֮������
                //speech[y] =(short)((short)pcmFrame_8b2[x+1] << 7);
                // 3 - ȡ����������ƽ��ֵ
                //ush1 = (short)pcmFrame_8b2[x+0];
                //ush2 = (short)pcmFrame_8b2[x+1];
                //ush = (ush1 + ush2) >> 1;
                //speech[y] = (short)((short)ush << 7);
            }
        }
        else
            if (nBitsPerSample==16 && nChannels==1)
            {
                nRead = fread(pcmFrame_16b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                for(x=0; x<PCM_FRAME_SIZE; x++)
                {
                    speech[x] = (short)pcmFrame_16b1[x+0];
                }
            }
            else
                if (nBitsPerSample==16 && nChannels==2)
                {
                    nRead = fread(pcmFrame_16b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                    for( x=0, y=0; y<PCM_FRAME_SIZE; y++,x+=2 )
                    {
                        //speech[y] = (short)pcmFrame_16b2[x+0];
                        speech[y] = (short)((int)((int)pcmFrame_16b2[x+0] + (int)pcmFrame_16b2[x+1])) >> 1;
                    }
                }

                // ������������ݲ���һ��������PCM֡, �ͷ���0
                if (nRead<PCM_FRAME_SIZE*nChannels) return 0;

                return nRead;
}

// WAVE��Ƶ����Ƶ����8khz 
// ��Ƶ������Ԫ�� = 8000*0.02 = 160 (�ɲ���Ƶ�ʾ���)
// ������ 1 : 160
//        2 : 160*2 = 320
// bps��������(sample)��С
// bps = 8 --> 8λ unsigned char
//       16 --> 16λ unsigned short
int EncodePCMFileToAMRFile(FILE* fppcm, FILE* fpamr, int nChannels, int nBitsPerSample)
{ 

    /* input speech vector */
    short speech[160];

    /* counters */
    int byte_counter, frames = 0, bytes = 0;

    /* pointer to encoder state structure */
    int *enstate;

    /* requested mode */
    enum Mode req_mode = MR122;
    int dtx = 0;

    /* bitstream filetype */
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];

    if ((fppcm == NULL)||(fpamr == NULL))
    {
        return 0;
    }
   
    /* write magic number to indicate single channel AMR file storage format */
    bytes = fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);

    /* skip to pcm audio data*/
   // SkipToPCMAudioData(fpwave);

    enstate = (int*)Encoder_Interface_init(dtx);

    while(1)
    {
        // read one pcm frame
        if (!ReadPCMFrame(speech, fppcm, nChannels, nBitsPerSample)) break;

        frames++;

        /* call encoder */
        byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);

        bytes += byte_counter;
        fwrite(amrFrame, sizeof (unsigned char), byte_counter, fpamr);
    }

    Encoder_Interface_exit(enstate);   

    return frames;
}

//decode
void WriteWAVEFileHeader(FILE* fpwave, int nFrame)
{
	char tag[10] = "";

	// 1. дRIFFͷ
	RIFFHEADER riff;
	strcpy(tag, "RIFF");
	memcpy(riff.chRiffID, tag, 4);
	riff.nRiffSize = 4                                     // WAVE
		+ sizeof(XCHUNKHEADER)               // fmt 
		+ sizeof(WAVEFORMATX)           // WAVEFORMATX
		+ sizeof(XCHUNKHEADER)               // DATA
		+ nFrame*160*sizeof(short);    // 
	strcpy(tag, "WAVE");
	memcpy(riff.chRiffFormat, tag, 4);
	fwrite(&riff, 1, sizeof(RIFFHEADER), fpwave);

	// 2. дFMT��
	XCHUNKHEADER chunk;
	WAVEFORMATX wfx;
	strcpy(tag, "fmt ");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = sizeof(WAVEFORMATX);
	fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
	memset(&wfx, 0, sizeof(WAVEFORMATX));
	wfx.nFormatTag = 1;
	wfx.nChannels = 1; // ������
	wfx.nSamplesPerSec = 8000; // 8khz
	wfx.nAvgBytesPerSec = 16000;
	wfx.nBlockAlign = 2;
	wfx.nBitsPerSample = 16; // 16λ
	fwrite(&wfx, 1, sizeof(WAVEFORMATX), fpwave);

	// 3. дdata��ͷ
	strcpy(tag, "data");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = nFrame*160*sizeof(short);
	fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
}

const int myround(const double x)
{
	return((int)(x+0.5));
} 

// ����֡ͷ���㵱ǰ֡��С
int caclAMRFrameSize(unsigned char frameHeader)
{
	int mode;
	int temp1 = 0;
	int temp2 = 0;
	int frameSize;

	temp1 = frameHeader;

	// ���뷽ʽ��� = ֡ͷ��3-6λ
	temp1 &= 0x78; // 0111-1000
	temp1 >>= 3;

	mode = amrEncodeMode[temp1];

	// ����amr��Ƶ����֡��С
	// ԭ��: amr һ֡��Ӧ20ms����ôһ����50֡����Ƶ����
	temp2 = myround((double)(((double)mode / (double)AMR_FRAME_COUNT_PER_SECOND) / (double)8));

	frameSize = myround((double)temp2 + 0.5);
	return frameSize;
}

// ����һ��֡ - (�ο�֡)
// ����ֵ: 0-����; 1-��ȷ
int ReadAMRFrameFirst(FILE* fpamr, unsigned char frameBuffer[], int* stdFrameSize, unsigned char* stdFrameHeader)
{
	memset(frameBuffer, 0, sizeof(frameBuffer));

	// �ȶ�֡ͷ
	fread(stdFrameHeader, 1, sizeof(unsigned char), fpamr);
	if (feof(fpamr)) return 0;

	// ����֡ͷ����֡��С
	*stdFrameSize = caclAMRFrameSize(*stdFrameHeader);

	// ����֡
	frameBuffer[0] = *stdFrameHeader;
	fread(&(frameBuffer[1]), 1, (*stdFrameSize-1)*sizeof(unsigned char), fpamr);
	if (feof(fpamr)) return 0;

	return 1;
}

// ����ֵ: 0-����; 1-��ȷ
int ReadAMRFrame(FILE* fpamr, unsigned char frameBuffer[], int stdFrameSize, unsigned char stdFrameHeader)
{
	int bytes = 0;
	unsigned char frameHeader; // ֡ͷ

	memset(frameBuffer, 0, sizeof(frameBuffer));

	// ��֡ͷ
	// ����ǻ�֡(���Ǳ�׼֡ͷ)�����������һ���ֽڣ�ֱ��������׼֡ͷ
	while(1)
	{
		bytes = fread(&frameHeader, 1, sizeof(unsigned char), fpamr);
		if (feof(fpamr)) return 0;
		if (frameHeader == stdFrameHeader) break;
	}

	// ����֡����������(֡ͷ�Ѿ�����)
	frameBuffer[0] = frameHeader;
	bytes = fread(&(frameBuffer[1]), 1, (stdFrameSize-1)*sizeof(unsigned char), fpamr);
	if (feof(fpamr)) return 0;

	return 1;
}

// ��AMR�ļ������pcm�ļ�
int DecodeAMRFileToWAVFile(FILE* fpamr, FILE* fpwav, char* audioWavPlayPath)
{
	char magic[8];
	void * destate;
	int nFrameCount = 0;
	int stdFrameSize;
	unsigned char stdFrameHeader;

	unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
	short pcmFrame[PCM_FRAME_SIZE];

	if ((fpwav == NULL)||(fpamr == NULL))
	{
		return 0;
	}
	
	// ���amr�ļ�ͷ
	fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);
	if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
	{
		fclose(fpamr);
		return 0;
	}	

	WriteWAVEFileHeader(fpwav, nFrameCount);

	/* init decoder */
	destate = Decoder_Interface_init();

	// ����һ֡ - ��Ϊ�ο�֡
	memset(amrFrame, 0, sizeof(amrFrame));
	memset(pcmFrame, 0, sizeof(pcmFrame));
	ReadAMRFrameFirst(fpamr, amrFrame, &stdFrameSize, &stdFrameHeader);

	// ����һ��AMR��Ƶ֡��PCM����
	Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
	nFrameCount++;
	fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwav);

	// ��֡����AMR��д��pcm�ļ���
	while(1)
	{
		memset(amrFrame, 0, sizeof(amrFrame));
		memset(pcmFrame, 0, sizeof(pcmFrame));
		if (!ReadAMRFrame(fpamr, amrFrame, stdFrameSize, stdFrameHeader)) break;

		// ����һ��AMR��Ƶ֡��PCM���� (8k-16b-������)
		Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
		nFrameCount++;
		fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwav);
	}
	//NSLog(@"frame = %d", nFrameCount);
	Decoder_Interface_exit(destate);

	fclose(fpwav);

	// ��дWAVE�ļ�ͷ
	fpwav = fopen(audioWavPlayPath, "r+");
	WriteWAVEFileHeader(fpwav, nFrameCount);

	fclose(fpwav);

	return nFrameCount;
}


void  AmrEncode::init()
{
	//bzero(m_data,1024*1024*2);
	memset(m_data,0, 1024*1024*2);
	m_attachlen = 0;
	m_cur = m_data;
	m_writelen = 0;
	m_fpamr = NULL;
}

void  AmrEncode::open(const char* pchAMRFileName)
{
	// ��������ʼ��amr�ļ�
	
	//m_pchAMRFileName = pchAMRFileName;
	
	
    m_fpamr = fopen(pchAMRFileName, "wb");
    if (m_fpamr == NULL)
    {
        return ;
    }
	
    /* write magic number to indicate single channel AMR file storage format */
    int bytes = fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), m_fpamr);
	
	int dtx = 0;
	
    m_enstate = (int*)Encoder_Interface_init(dtx);
}

void  AmrEncode::close()
{
	Encoder_Interface_exit(m_enstate);
    fclose(m_fpamr);
}


int   AmrEncode::EncodeBufferToAMRFile()
{
	/* requested mode */
    enum Mode req_mode = MR122;	
	
	/* counters */
    int byte_counter, frames = 0, bytes = 0;
	
	/* bitstream filetype */
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
	
	/* input speech vector */
    short speech[160];
	
	
	while(1)
    {
        // read one pcm frame
        if (!ProcessPCMFrame(speech, 1, 16)) break;
		
        frames++;
		
        /* call encoder */
        byte_counter = Encoder_Interface_Encode(m_enstate, req_mode, speech, amrFrame, 0);
		
        bytes += byte_counter;
		
        fwrite(amrFrame, sizeof (unsigned char), byte_counter, m_fpamr );
		
		
    }
	
	
	
	
	
	return 0;	
}

void AmrEncode::attachdata(char* buffer,int len)
{
	//void overfloat
	if(m_attachlen + len >=1024*1024*2)
	{
		
		//NSLog(@"foolbear - total attachlen =  %d", m_attachlen);
		return;
	}
	
	memcpy(m_data + m_attachlen,buffer,len);
	
	m_attachlen+=len;
	
	
	//NSLog(@"foolbear - attachlen =  %d", m_attachlen);
	
	
	
	
}

int AmrEncode::ProcessPCMFrame(short speech[], int nChannels, int nBitsPerSample)
{
	//int nRead = 0;
    int x = 0, y=0;
    //unsigned short ush1=0, ush2=0, ush=0;
	
    // ԭʼPCM��Ƶ֡����
    unsigned char pcmFrame_8b1[PCM_FRAME_SIZE];
    //unsigned char pcmFrame_8b2[PCM_FRAME_SIZE<<1];
    unsigned short pcmFrame_16b1[PCM_FRAME_SIZE];
//    unsigned short pcmFrame_16b2[PCM_FRAME_SIZE<<1];
	
	
	//NSLog(@"foolbear - attachlen =  %d,writelen = %d", m_attachlen,m_writelen);
	
	
	
	
		if (nBitsPerSample==8 && nChannels==1)
		{
			//nRead = fread(pcmFrame_8b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
			memcpy(pcmFrame_8b1,m_cur,PCM_FRAME_SIZE*nChannels);
			
			m_writelen += PCM_FRAME_SIZE*nChannels;
			
			m_cur = m_data + m_writelen;

			
			for(x=0; x<PCM_FRAME_SIZE; x++)
			{
				speech[x] =(short)((short)pcmFrame_8b1[x] << 7);
			}
		}
		else if(nBitsPerSample==16 && nChannels==1)
		{
			//nRead = fread(pcmFrame_8b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
			memcpy(pcmFrame_16b1,m_cur,2*PCM_FRAME_SIZE*nChannels);
			
			m_writelen += 2*PCM_FRAME_SIZE*nChannels;
			
			m_cur = m_data + m_writelen;
		
			
			for(x=0; x<PCM_FRAME_SIZE; x++)
			{
				speech[x] = (short)pcmFrame_16b1[x+0];
			}
		}

//	else 
//	{
//		NSLog(@"foolbear - total attachlen =  %d,writelen = %d", m_attachlen,m_writelen);
//		
//		
//		return 0;
//	}

	

	
	// ������������ݲ���һ��������PCM֡, �ͷ���0
	
	if((m_attachlen - m_writelen) < PCM_FRAME_SIZE*nChannels) return 0;
	
	//if(m_writelen >= m_attachlen) return 0;
	
	return PCM_FRAME_SIZE*nChannels;
	
}
